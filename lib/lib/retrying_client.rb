require 'delegate'

class RetryingClient < DelegateClass(DistanceMatrixClient)

  def results(*, tries: 3)
    super()
  rescue
    tries -= 1
    sleep sleep_time(tries)
    retry if tries > 0
    raise
  end

  def sleep_time(tries)
    cost = ENV.fetch('SLEEP_COST').to_i || 1
    attempts = 4 - tries
    (attempts ** 3) * cost
  end

end
