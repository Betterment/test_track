require 'rails_helper'

RSpec.describe Api::V2::Migrations::AppRemoteKillsController do
  let(:feature_gate) { FactoryBot.create(:feature_gate) }
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
        split: feature_gate.name,
        reason: "my_bug_2019",
        override_to: "false",
        first_bad_version: "1.0",
        fixed_version: "1.1"
      }, as: :json

      expect(response).to have_http_status(:no_content)
      result = app.remote_kills.first
      expect(result.split).to eq(feature_gate)
      expect(result.reason).to eq("my_bug_2019")
      expect(result.override_to).to eq("false")
      expect(result.first_bad_version).to eq(AppVersion.new("1.0"))
      expect(result.fixed_version).to eq(AppVersion.new("1.1"))
    end

    it "updates an existing feature completion with a well-formed request" do
      remote_kill = FactoryBot.create(:app_remote_kill, app: app, split: feature_gate, first_bad_version: "1.0", fixed_version: nil)

      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: {
        split: feature_gate.name,
        reason: remote_kill.reason,
        override_to: "false",
        first_bad_version: "0.9",
        fixed_version: "1.1"
      }, as: :json

      expect(response).to have_http_status(:no_content)
      remote_kill.reload
      expect(remote_kill.first_bad_version).to eq(AppVersion.new("0.9"))
      expect(remote_kill.fixed_version).to eq(AppVersion.new("1.1"))
    end

    it "nulls fixed_version with a null version via JSON request" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: {
        split: feature_gate.name,
        reason: "big_bug",
        override_to: "false",
        first_bad_version: "0.9",
        fixed_version: nil
      }, as: :json

      expect(response).to have_http_status(:no_content)
      result = app.remote_kills.first
      expect(result.fixed_version).to eq(nil)
    end

    it "nulls fixed_version via a URLENCODED request" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: {
        split: feature_gate.name,
        reason: "big_bug",
        override_to: "false",
        first_bad_version: "0.9",
        fixed_version: nil
      }

      expect(response).to have_http_status(:no_content)
      result = app.remote_kills.first
      expect(result.fixed_version).to eq(nil)
    end

    it "is invalid with a bad reason" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: {
        split: feature_gate.name,
        reason: "noWayJose",
        override_to: "false",
        first_bad_version: "1.0",
        fixed_version: "1.1"
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']['reason'].first).to include("alphanumeric snake_case")
    end
  end
end
