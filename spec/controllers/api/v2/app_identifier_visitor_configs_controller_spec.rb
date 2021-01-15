require 'rails_helper'

RSpec.describe Api::V2::AppIdentifierVisitorConfigsController do
  describe "#show" do
    let(:app) { FactoryBot.create(:app) }
    let(:identifier_type) { FactoryBot.create(:identifier_type, name: "clown_id") }
    let(:feature_gate) { FactoryBot.create(:feature_gate, name: "blab_enabled", registry: { false: 50, true: 50 }) }
    let(:visitor) { FactoryBot.create(:visitor) }
    let(:identifier) { FactoryBot.create(:identifier, visitor: visitor) }

    it "has knocked-out weightings and it doesn't include a non-force assignment for a feature gate that isn't feature complete" do
      FactoryBot.create(
        :assignment,
        visitor: visitor,
        split: feature_gate,
        variant: "true"
      )

      get :show, params: {
        app_name: app.name,
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30Z",
        identifier_type_name: identifier.identifier_type.name,
        identifier_value: identifier.value
      }

      expect(response).to have_http_status :ok
      expect(response_json['splits'][0]['name']).to eq('blab_enabled')
      expect(response_json['splits'].first['variants'].first).to eq('name' => 'false', 'weight' => 100)
      expect(response_json['splits'].first['variants'].last).to eq('name' => 'true', 'weight' => 0)
      expect(response_json['splits'][0]['feature_gate']).to eq(true)
      expect(response_json['visitor']['assignments']).to be_empty
    end

    it "has real weightings and it includes a non-force assignment for a feature gate that is feature complete" do
      FactoryBot.create(
        :assignment,
        visitor: visitor,
        split: feature_gate,
        variant: "true"
      )

      FactoryBot.create(
        :app_feature_completion,
        feature_gate: feature_gate,
        app: app,
        version: "0.1"
      )

      get :show, params: {
        app_name: app.name,
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30Z",
        identifier_type_name: identifier.identifier_type.name,
        identifier_value: identifier.value
      }

      expect(response).to have_http_status :ok
      expect(response_json['splits'][0]['name']).to eq('blab_enabled')
      expect(response_json['splits'].first['variants'].first).to eq('name' => 'false', 'weight' => 50)
      expect(response_json['splits'].first['variants'].last).to eq('name' => 'true', 'weight' => 50)
      expect(response_json['splits'][0]['feature_gate']).to eq(true)

      expect(response_json['visitor']['id']).to eq(visitor.id)
      expect(response_json['visitor']['assignments'].first['split_name']).to eq('blab_enabled')
      expect(response_json['visitor']['assignments'].first['variant']).to eq('true')
    end

    it "returns unprocessable_entity if the app_build url params are invalid" do
      get :show, params: {
        app_name: app.name,
        version_number: "01.0",
        build_timestamp: "2019-04-16T14:35:30Z",
        identifier_type_name: identifier.identifier_type.name,
        identifier_value: identifier.value
      }

      expect(response).to have_http_status :unprocessable_entity
    end
  end
end
