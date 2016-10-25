worker_count = Integer(ENV['PUMA_WORKER_COUNT'])
workers worker_count

thread_count = Integer(ENV['PUMA_THREAD_COUNT'])
threads thread_count, thread_count

environment ENV['RAILS_ENV'] || 'development'

bind 'unix:///var/run/puma/testtrack.sock'

daemonize true
pidfile '/var/run/puma/testtrack.pid'

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
