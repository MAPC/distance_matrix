class RunTask

  def perform!
    boot!
    loop do
      break if Waitlist.empty?
      Waitlist.transaction do
        exec 'LOCK TABLE waitlist IN ACCESS EXCLUSIVE MODE'
        @origin_id = Waitlist.first.destroy.id
      end
      # TODO design batching
      # BatchMaker.new(@origin_id).in_batches(of: 100) do |destinations, mode|
        # Switch to keyword params, requiring :destinations
        DistanceMatrix.new(@origin_id, mode, @key).results
      # end
    end
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

  def teardown!
    @key.release!
  end

  private

  def modes
    [:transit, :walking]
  end

  def exec(query)
    ActiveRecord::Base.connection.execute(query)
  end

end
