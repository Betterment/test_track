require 'rails_helper'

RSpec.describe Api::V4::AppVisitorConfigsController do
  describe "#show" do
    before do
      allow(Rails.configuration).to receive(:experience_sampling_weight).and_return(10)
    end

    let(:app) { FactoryBot.create(:app) }
    let(:feature_gate) { FactoryBot.create(:feature_gate, name: "blab_enabled", registry: { false: 50, true: 50 }) }
    let(:visitor) { FactoryBot.create(:visitor) }

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
        visitor_id: visitor.id
      }

      expect(response).to have_http_status :ok
      expect(response_json['splits'].first['name']).to eq('blab_enabled')
      expect(response_json['splits'].first['variants'].first).to eq('name' => 'false', 'weight' => 100)
      expect(response_json['splits'].first['variants'].last).to eq('name' => 'true', 'weight' => 0)
      expect(response_json['splits'].first['feature_gate']).to be(true)
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
        visitor_id: visitor.id
      }

      expect(response).to have_http_status :ok

      expect(response_json['splits'][0]['name']).to eq('blab_enabled')
      expect(response_json['splits'].first['variants'].first).to eq('name' => 'false', 'weight' => 50)
      expect(response_json['splits'].first['variants'].last).to eq('name' => 'true', 'weight' => 50)
      expect(response_json['splits'][0]['feature_gate']).to be(true)

      expect(response_json['visitor']['assignments'].first['split_name']).to eq('blab_enabled')
      expect(response_json['visitor']['assignments'].first['variant']).to eq('true')
    end

    it "includes sampling weight" do
      get :show, params: {
        app_name: app.name,
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30Z",
        visitor_id: visitor.id
      }

      expect(response).to have_http_status :ok
      expect(response_json['experience_sampling_weight']).to eq(10)
    end

    it "returns unprocessable_entity if the app_build url params are invalid" do
      get :show, params: {
        app_name: app.name,
        version_number: "01.0",
        build_timestamp: "2019-04-16T14:35:30Z",
        visitor_id: visitor.id
      }

      expect(response).to have_http_status :unprocessable_entity
    end
  end
end
