class RunTask

  def perform!
    boot!
    work!
  rescue Interrupt => e
    puts '----> Exiting gracefully due to error or interrupt.'
    puts "#{e.inspect}" if e
  ensure
    teardown!
  end

  def boot!
    ApiKey.transaction do
      exec 'LOCK TABLE api_keys IN ACCESS EXCLUSIVE MODE'
      @key = ApiKey.available.first
      raise NoAvailableKeyError unless @key
      @key.claim!
    end
  end

  def work!
    loop do
      begin
        break if Waitlist.available.count == 0
        get_next_origin
        perform_distance_matrix!
      rescue
        @origin.release! if @origin
        raise
      end
    end
  end

  def teardown!
    @key.release! if @key
  end

  private

  def get_next_origin
    Waitlist.transaction do
      exec 'LOCK TABLE waitlist IN ACCESS EXCLUSIVE MODE'
      @origin = Waitlist.available.first
      @origin.claim!
    end
  end

  def perform_distance_matrix!
    BatchMaker.new(origin_id: @origin.origin_id).in_batches do |group, mode|
      origin = TravelTime.find_by(input_id: @origin.origin_id).origin
      destinations = group.map(&:destination)
      # TODO: Replace with RetryingClient, but it's returning a hash
      # upon initialization, at the moment.
      client_class = DistanceMatrixClient
      RetryingClient.new(client_class.new(
        key: @key.token,    mode: mode,
        origins: [origin], destinations: destinations
      )).durations.each_with_index { |d,i|
        group[i].update_attribute(:time, d)
      }
    end
  end

  def exec(query)
    ActiveRecord::Base.connection.execute(query)
  end

end
