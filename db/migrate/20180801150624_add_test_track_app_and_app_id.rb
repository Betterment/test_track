class AddTestTrackAppAndAppId < ActiveRecord::Migration[5.0]
  class App < ActiveRecord::Base; end
  class IdentifierType < ActiveRecord::Base; end
  
  def up
    test_track_app = App.find_or_create_by!(name: 'TestTrack') do |app|
      app.auth_secret = SecureRandom.urlsafe_base64(32)
    end

    IdentifierType.find_or_create_by!(name: 'app_id') do |identifier_type|
      identifier_type.owner_app_id = test_track_app.id
    end
  end
end
