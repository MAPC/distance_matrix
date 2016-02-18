class RunTask

  def perform!
    boot!
    work!
  rescue Interrupt => e
    puts "----> Exiting RunTask gracefully due to #{e.inspect}."
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
      rescue => e
        puts "----> Error in work!: #{e.inspect}"
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
    BatchMaker.new(origin_id: @origin.origin_id).in_batches(of: 50) do |group, mode|
      origin = TravelTime.find_by(input_id: @origin.origin_id).origin
      destinations = group.map(&:destination)
      puts "\n\n----> Working on next batch:"
      puts "Origin:\t#{origin.inspect}"
      puts "Destinations: \t#{destinations.first(5)}"
      client = RetryingClient.new(DistanceMatrixClient.new(
        key: @key.token,    mode: mode,
        origins: [origin], destinations: destinations
      ))
      puts '----> Requesting URL...'
      puts "\t#{URI.unescape(client.to_request.to_s)}"
      client.durations.each_with_index { |d,i|
        group[i].update_attribute(:time, d)
      }
    end
  end

  def exec(query)
    ActiveRecord::Base.connection.execute(query)
  end

end
