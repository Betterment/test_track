require 'rails_helper'

RSpec.describe Api::V1::SplitRegistriesController, type: :controller do
  let(:split_1) { FactoryGirl.create :split, name: "one", finished_at: Time.zone.now, registry: { all: 100 } }
  let(:split_2) { FactoryGirl.create :split, name: "two", registry: { on: 50, off: 50 } }
  let(:split_3) { FactoryGirl.create :split, name: "three", registry: { true: 99, false: 1 } }

  describe "#show" do
    it "returns empty with no active splits" do
      get :show
      expect(response).to have_http_status :ok
      expect(response_json).to eq({})
    end

    it "returns the full split registry" do
      expect(split_1).to be_finished
      expect(split_2).not_to be_finished
      expect(split_3).not_to be_finished

      get :show

      expect(response).to have_http_status :ok
      expect(response_json).to eq(
        "two" => { "on" => 50, "off" => 50 },
        "three" => { "true" => 99, "false" => 1 }
      )
    end
  end
end
