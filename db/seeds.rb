# To generate a seed for an app called "widget_maker" run `rake seed_app[widget_maker]`

if Rails.env.development?
  seed_apps_filename = Rails.root.join('db/seed_apps.yml')
  if File.exists?(seed_apps_filename)
    YAML.load_file(seed_apps_filename).each do |app_name, auth_secret|
      App.create_with(auth_secret: auth_secret).find_or_create_by!(name: app_name).update!(auth_secret: auth_secret)
      puts "Ensured #{app_name} app"
    end
  end
end

test_track_app = App.find_or_create_by!(name: 'TestTrack') do |app|
  app.auth_secret = SecureRandom.urlsafe_base64(32)
end

IdentifierType.find_or_create_by!(name: 'app_id') do |identifier_type|
  identifier_type.owner_app = test_track_app
end
