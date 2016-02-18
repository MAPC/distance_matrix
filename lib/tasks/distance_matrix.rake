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
    puts "----> Running task `task:run` in #{DATABASE_ENV} environment"
    RunTask.new.perform!
    puts '----> Exiting...'
    exit 0
  end

  desc 'Statistics on tables'
  task stats: :environment do
    StatisticsTask.new.perform!
  end
end
