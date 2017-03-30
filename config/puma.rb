workers Integer(ENV['PUMA_WORKER_COUNT'] || ENV['WEB_CONCURRENCY'] || 2)
thread_count = Integer(ENV['PUMA_THREAD_COUNT'] || ENV['RAILS_MAX_THREADS'] || 5)
threads thread_count, thread_count

preload_app!

rackup      DefaultRackup

rails_env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'

if rails_env == 'development' || ENV['PORT']
  port ENV.fetch('PORT', '3000')
else
  bind 'unix:///var/run/puma/testtrack.sock'
end

environment rails_env

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
