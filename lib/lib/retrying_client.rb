require 'delegate'

class RetryingClient < DelegateClass(DistanceMatrixClient)

  def results(*, tries: 3)
    super()
  rescue OverQueryLimitError
    tries -= 1
    time_to_sleep = over_limit_sleep_time(tries)
    log_sleep(time_to_sleep)
    sleep time_to_sleep.seconds
  rescue GoogleApiError => e
    # Handles other GoogleApiErrors that don't need as long of
    # a sleep time to be safe.
    tries -= 1
    sleep sleep_time(tries)
    retry if tries > 0
    raise
  end

  def sleep_time(tries)
    attempts = 4 - tries
    (attempts ** 3) * cost
  end

  def over_limit_sleep_time(tries)
    time = case tries
    when 1 then 10.minutes
    when 2 then 1.hour
    when 3 then 3.hours
    end
    time ** cost
  end

  private

  def cost
    ENV.fetch('SLEEP_COST').to_i || 1
  end

  def log_sleep(time)
    puts "----> Over Query Limit, sleeping for #{time}"
    puts "----> Trying again #{time.from_now.strftime('%I:%M %p on %B %e %Y')}"
  end

end
