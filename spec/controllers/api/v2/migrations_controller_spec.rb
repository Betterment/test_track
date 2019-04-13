require 'rails_helper'

RSpec.describe Api::V2::MigrationsController do
  let(:app) { FactoryBot.create(:app) }

  describe "#create" do
    it "is unauthorized with bad auth" do
      http_authenticate username: app.name, auth_secret: 'bad bad bad'
      post :create, as: :json
      expect(response).to have_http_status :unauthorized
    end

    it "persists with a well-formed request" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: {
        version: "123"
      }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(app.migrations.where(version: "123")).to be_present
    end

    it "is idempotent" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: {
        version: "123"
      }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(app.migrations.where(version: "123")).to be_present

      post :create, params: {
        version: "123"
      }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(app.migrations.where(version: "123")).to be_present
    end
  end

  describe "#index" do
    it "returns all of an apps migration versions and no others" do
      app.migrations.create!(version: "123")
      app.migrations.create!(version: "124")
      other_app = FactoryBot.create(:app)
      other_app.migrations.create!(version: "notgood")

      http_authenticate username: app.name, auth_secret: app.auth_secret
      get :index

      expect(response).to have_http_status(:ok)
      expect(response_json).to eq [
        { 'version' => '123' },
        { 'version' => '124' }
      ]
    end
  end
end
