require 'rails_helper'

RSpec.describe Api::V2::Migrations::AppFeatureCompletionsController do
  let(:feature_gate) { FactoryBot.create(:feature_gate) }
  let(:experiment) { FactoryBot.create(:experiment) }
  let(:app) { FactoryBot.create(:app) }

  describe "#create" do
    it "is unauthorized with bad auth" do
      http_authenticate username: app.name, auth_secret: 'bad bad bad'
      post :create, as: :json
      expect(response).to have_http_status :unauthorized
    end

    it "persists with a well-formed request" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: feature_gate.name, version: "1.0" }, as: :json

      expect(response).to have_http_status(:no_content)
      result = app.feature_completions.first
      expect(result.feature_gate).to eq(feature_gate)
      expect(result.version).to eq(AppVersion.new("1.0"))
    end

    it "updates an existing feature completion with a well-formed request" do
      feature_completion = FactoryBot.create(:app_feature_completion, app: app, feature_gate: feature_gate, version: "0.9")
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: feature_gate.name, version: "1.0" }, as: :json

      expect(response).to have_http_status(:no_content)

      feature_completion.reload
      expect(feature_completion.version).to eq(AppVersion.new("1.0"))
    end

    it "destroys feature completions with null version via JSON request" do
      FactoryBot.create(:app_feature_completion, app: app, feature_gate: feature_gate, version: "1.0")

      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: feature_gate.name, version: nil }, as: :json

      expect(response).to have_http_status(:no_content)

      expect(app.feature_completions.reload).to be_empty
    end

    it "destroys idempotently" do
      FactoryBot.create(:app_feature_completion, app: app, feature_gate: feature_gate, version: "1.0")

      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: feature_gate.name, version: nil }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(app.feature_completions.reload).to be_empty

      post :create, params: { feature_gate: feature_gate.name, version: nil }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(app.feature_completions.reload).to be_empty
    end

    it "destroys feature completions with null version via URLENCODED request" do
      FactoryBot.create(:app_feature_completion, app: app, feature_gate: feature_gate, version: "1.0")

      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: feature_gate.name, version: nil }

      expect(response).to have_http_status(:no_content)

      expect(app.feature_completions).to be_empty
    end

    it "is invalid with an experiment" do
      http_authenticate username: app.name, auth_secret: app.auth_secret
      post :create, params: { feature_gate: experiment.name, version: "1.0" }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']['feature_gate'].first).to include("must be a feature gate")
    end
  end
end
