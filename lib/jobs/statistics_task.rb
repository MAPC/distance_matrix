class StatisticsTask
  def perform!
    puts message
  end

  def message
    msg = "\n"
    msg << "Travel Times:\t #{times_with_time} complete of #{times_total} (#{pct_done}% done)"
    msg << ", #{distinct_origins} distinct\n"
    msg << "Waitlist:\t #{waiters} remaining of #{waitlist} total\n"
    msg << "API Keys:\t #{taken_keys} claimed of #{total_keys} total (#{free_keys} free)\n"

    if distinct_origins != waitlist
      msg << "\n----> WARNING: Waitlist is not fully built, because the Waitlist"
      msg << " should have the same number of records as distinct TravelTimes.\n"
      msg << "----> Run `rake task:setup` to build the waitlist.\n"
    end

    msg << "\n"
    msg
  end

  def taken_keys
    ApiKey.claimed.count
  end

  def free_keys
    ApiKey.available.count
  end

  def total_keys
    ApiKey.count
  end

  def waitlist
    Waitlist.count
  end

  def waiters
    Waitlist.available.count
  end

  def claimed
    Waitlist.claimed.count
  end

  def times_with_time
    TravelTime.where.not(time: nil).count
  end

  def distinct_origins
    TravelTime.select(:input_id).distinct.count
  end

  def times_total
    TravelTime.count
  end

  def pct_done
    times_with_time / times_total.to_f * 100
  end

end
