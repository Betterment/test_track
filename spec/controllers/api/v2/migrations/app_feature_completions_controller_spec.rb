require 'rails_helper'

RSpec.describe Api::V2::Migrations::AppFeatureCompletionsController do
  let(:feature_gate) { FactoryBot.create(:feature_gate) }
  let(:experiment) { FactoryBot.create(:experiment) }
  let(:app) { FactoryBot.create(:app) }

  describe "#create" do
    it "is unauthorized with bad auth" do
      http_authenticate username: app.name, auth_secret: 'bad bad bad'
      post :create
      expect(response).to have_http_status :unauthorized
    end

    it "persists with a well-formed request" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: feature_gate.name, version: "1.0" }

      expect(response).to have_http_status(:no_content)
      result = app.feature_completions.first
      expect(result.feature_gate).to eq(feature_gate)
      expect(result.version).to eq(AppVersion.new("1.0"))
    end

    it "blows up with an experiment" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: experiment.name, version: "1.0" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']['feature_gate'].first).to include("must be a feature gate")
    end
  end
end
