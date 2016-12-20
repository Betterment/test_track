rails_env = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
environment rails_env

if rails_env == 'development'
  thread_count = Integer(ENV.fetch('PUMA_THREAD_COUNT', '5'))
  threads thread_count, thread_count
  port ENV.fetch('PORT', '3000')
else
  worker_count = Integer(ENV.fetch('PUMA_WORKER_COUNT'))
  workers worker_count
  thread_count = Integer(ENV.fetch('PUMA_THREAD_COUNT'))
  threads thread_count, thread_count
  bind 'unix:///var/run/puma/testtrack.sock'
end

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
