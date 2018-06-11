require 'rails_helper'

RSpec.describe Api::V2::SplitRegistriesController, type: :controller do
  let(:split_1) { FactoryBot.create :split, name: "one", finished_at: Time.zone.now, registry: { all: 100 } }
  let(:split_2) { FactoryBot.create :split, name: "two", registry: { on: 50, off: 50 } }
  let(:split_3) { FactoryBot.create :split, name: "three_enabled", registry: { true: 99, false: 1 }, feature_gate: true }

  describe "#show" do
    before do
      allow(SplitRegistry.instance).to receive(:experience_sampling_weight).and_return(10)
    end

    it "includes sampling weight" do
      get :show
      expect(response).to have_http_status :ok
      expect(response_json['experience_sampling_weight']).to eq(10)
    end

    it "returns empty with no active splits" do
      get :show
      expect(response).to have_http_status :ok
      expect(response_json['splits']).to eq({})
    end

    it "returns the full split registry" do
      expect(split_1).to be_finished
      expect(split_2).not_to be_finished
      expect(split_3).not_to be_finished

      get :show

      expect(response).to have_http_status :ok
      expect(response_json['splits']).to eq(
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
  end
end
