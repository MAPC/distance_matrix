class RunTask

  def perform!
  end

  def boot!
    @key = ApiKey.available.first
    raise NoAvailableKeyError unless @key
    @key.claim!
  end

  def teardown!
    @key.release!
  end

end
