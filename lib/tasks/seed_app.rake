desc "Create a new seed app including a random auth_secret for local development"
task :seed_app, [:app_name] do |_, opts|
  seed_app_filename = Rails.root.join('db/seed_apps.yml')
  app_name = opts[:app_name]
  if app_name.blank?
    puts "You must provide an app_name argument, e.g. rake seed_app[my_fantastic_app]"
    next
  end

  existing_apps = File.exist?(seed_app_filename) ? YAML.load_file(seed_app_filename) : {}
  auth_secret = "#{app_name}_development_#{SecureRandom.urlsafe_base64(32)}"

  existing_apps[app_name] = auth_secret
  File.open(seed_app_filename, 'w') { |f| f.write(YAML.dump(existing_apps)) }

  Rake::Task["db:seed"].invoke

  puts "\n#{app_name} configured in db/seed_apps.yml and loaded into your database.\n\n"
  puts "Set the following environment variable in your app (e.g. via .powenv):\n\n"
  puts "export TEST_TRACK_API_URL=http://#{app_name}:#{auth_secret}@testtrack.dev/\n\n"
end
