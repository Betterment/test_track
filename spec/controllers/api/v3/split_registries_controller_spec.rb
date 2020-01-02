require 'rails_helper'

RSpec.describe Api::V3::SplitRegistriesController, type: :controller do
  let(:split_1) { FactoryBot.create :split, name: "one", finished_at: Time.zone.parse('2019-11-13'), registry: { all: 100 } }
  let(:split_2) { FactoryBot.create :split, name: "two", registry: { on: 50, off: 50 } }
  let(:split_3) { FactoryBot.create :split, name: "three_enabled", registry: { true: 99, false: 1 }, feature_gate: true }

  describe "#show" do
    before do
      allow(ENV).to receive(:fetch).with('EXPERIENCE_SAMPLING_WEIGHT', any_args).and_return(10)
    end

    it "includes sampling weight" do
      get :show, params: { build_timestamp: '2019-11-11T14:35:30Z' }

      expect(response).to have_http_status :ok
      expect(response_json['experience_sampling_weight']).to eq(10)
    end

    it "returns empty with no active splits on the timestamp" do
      expect(split_1).to be_finished

      get :show, params: { build_timestamp: '2019-11-14T14:35:30Z' }

      expect(response).to have_http_status :ok
      expect(response_json['splits']).to eq({})
    end

    it "returns the full split registry of splits that are active during timestamp" do
      expect(split_1).to be_finished
      expect(split_2).not_to be_finished
      expect(split_3).not_to be_finished

      get :show, params: { build_timestamp: '2019-11-12T14:35:30Z' }

      expect(response).to have_http_status :ok
      expect(response_json['splits']).to eq(
        "one" => {
          "weights" => { "all" => 100 },
          "feature_gate" => false
        },
        "two" => {
          "weights" => { "on" => 50, "off" => 50 },
          "feature_gate" => false
        },
        "three_enabled" => {
          "weights" => { "true" => 99, "false" => 1 },
          "feature_gate" => true
        }
      )
    end

    it "returns unprocessable_entity if the timestamp url param is invalid" do
      get :show, params: { build_timestamp: "2019-04-16 10:38:08 -0400" }

      expect(response).to have_http_status :unprocessable_entity
    end

    it "returns unprocessable_entity if the timestamp url param is missing" do
      get :show, params: { build_timestamp: "" }

      expect(response).to have_http_status :unprocessable_entity
    end
  end
end
