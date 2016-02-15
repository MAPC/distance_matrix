namespace :task do

  task :environment do
    # TODO Update me
    DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  desc 'Sets up the database before a run'
  task setup: :environment do
    puts '----> Running task `task:setup`'
    puts "----> Database Environment: #{DATABASE_ENV}"
    puts 'SELECT DISTINCT...'
    sleep 1
    puts '...finished!'
    exit 0
  end


  desc 'Runs the task'
  task run: :environment do
    puts '----> Running task `task:run`'
    RunTask.new.perform!
    puts '----> Exiting...'
    exit 0
  end
end
