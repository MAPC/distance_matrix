class SetupTask

  def perform!
    Waitlist.transaction do
      exec 'LOCK TABLE waitlist IN ACCESS EXCLUSIVE MODE'
      Waitlist.destroy_all
      exec "INSERT INTO waitlist (origin_id) SELECT DISTINCT target_id FROM #{travel_times}"
    end
  end

  private

  def exec(query)
    ActiveRecord::Base.connection.execute(query)
  end

  def travel_times
    TravelTime.table_name
  end

end
