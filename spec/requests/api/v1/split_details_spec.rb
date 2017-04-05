require 'rails_helper'

RSpec.describe Api::V1::SplitDetailsController, type: :request do
  describe 'GET /api/v1/split_details/:id' do
    let(:default_app) { FactoryGirl.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOf" }
    let(:split_with_no_details) { FactoryGirl.create :split, name: "fantastic_split" }
    let(:split_with_details) { FactoryGirl.create :split, name: "fantastic_split_with_information", platform: 'mobile', description: 'Greatest Split', assignment_criteria: "Must love problem solvers", hypothesis: 'Will solve all problems', location: 'Everywhere', owner: 'Me' } # rubocop:disable Metrics/LineLength

    before do
      http_authenticate username: default_app.name, password: default_app.auth_secret
    end

    it "responds with empty details if split has no details" do
      get "/api/v1/split_details/#{split_with_no_details.name}"

      expect(response_json).to eq(
        "name" => split_with_no_details.name,
        "hypothesis" => nil,
        "location" => nil,
        "assignment_criteria" => nil,
        "platform" => nil,
        "description" => nil,
        "owner" => nil
      )
    end

    it "responds with details if the split has details" do
      get "/api/v1/split_details/#{split_with_details.name}"

      expect(response_json).to eq(
        "name" => split_with_details.name,
        "hypothesis" => split_with_details.hypothesis,
        "location" => split_with_details.location,
        "assignment_criteria" => split_with_details.assignment_criteria,
        "platform" => split_with_details.platform,
        "description" => split_with_details.description,
        "owner" => split_with_details.owner
      )
    end

    it "blows up if split id is incorrect" do
      expect {
        get "/api/v1/split_details/i_am_not_a_real_split"
      }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
