namespace :task do

  task :environment do
    require_relative '../../environment'
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Sets up the database before a run'
  task setup: :environment do
    puts "----> Running task `task:setup` in #{DATABASE_ENV} environment"
    SetupTask.new.perform!
    puts "----> Created #{Waitlist.count} records in the waitlist"
    exit 0
  end

  desc 'Runs the task. Can be run concurrently by multiple workers.'
  task run: :environment do
    puts "----> Running task `task:setup` in #{DATABASE_ENV} environment"
    RunTask.new.perform!
    puts '----> Exiting...'
    exit 0
  end

  desc 'Statistics on tables'
  task stats: :environment do
    # TODO: Migrate this into its own task.
    taken_keys, free_keys, total_keys = ApiKey.claimed.count, ApiKey.available.count, ApiKey.count
    waitlist, waiters, claimed = Waitlist.count, Waitlist.available.count, Waitlist.claimed.count
    times_with_time = TravelTime.where.not(time: nil).count
    distinct_origins = TravelTime.select(:target_id).distinct.count
    times_total = TravelTime.count
    pct_done = times_with_time / times_total.to_f * 100

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
    puts msg
  end
end
