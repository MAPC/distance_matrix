class RunTask

  def perform!
    boot!
    work!
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
      break if Waitlist.empty?
      get_next_origin!
      perform_distance_matrix!
    end
  rescue
    teardown! # Release key if there's an error
  end

  def teardown!
    @key.release!
  end

  private

  def get_next_origin!
    Waitlist.transaction do
      exec 'LOCK TABLE waitlist IN ACCESS EXCLUSIVE MODE'
      @origin_id = Waitlist.first.destroy.id
    end
  end

  def perform_distance_matrix!
    BatchMaker.new(@origin_id).in_batches(of: 100) do |records, mode|
      destinations = records.map(&:destination)
      DistanceMatrix.new( key: @key.token, mode: mode,
        origins: [@origin], destinations: destinations
      ).each_with_index { |d,i| records[i].update_attribute(:time, d) }
    end
  end

  def exec(query)
    ActiveRecord::Base.connection.execute(query)
  end

end
