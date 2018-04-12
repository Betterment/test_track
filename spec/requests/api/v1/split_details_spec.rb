require 'rails_helper'

RSpec.describe Api::V1::SplitDetailsController, type: :request do
  describe 'GET /api/v1/split_details/:id' do
    let(:default_app) { FactoryBot.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOf" }

    before do
      http_authenticate username: default_app.name, password: default_app.auth_secret
    end

    context 'with no split details' do
      let(:split_with_no_details) { FactoryBot.create :split, registry: { hammer: 99, nail: 1 }, name: "fantastic_split" }

      it "responds with empty details" do
        get "/api/v1/split_details/#{split_with_no_details.name}"

        expect(response_json).to eq(
          "name" => split_with_no_details.name,
          "hypothesis" => nil,
          "location" => nil,
          "assignment_criteria" => nil,
          "platform" => nil,
          "description" => nil,
          "owner" => nil,
          "variant_details" => [
            {
              "name" => "hammer",
              "description" => nil
            },
            {
              "name" => "nail",
              "description" => nil
            }
          ]
        )
      end
    end

    context 'with split details' do
      let(:split_with_details) { FactoryBot.create :split, registry: { enabled: 99, disabled: 1 }, name: "fantastic_split_with_information", platform: 'mobile', description: 'Greatest Split', assignment_criteria: "Must love problem solvers", hypothesis: 'Will solve all problems', location: 'Everywhere', owner: 'Me' } # rubocop:disable Metrics/LineLength

      let!(:variant_detail_a) do
        FactoryBot.create(
          :variant_detail,
          split: split_with_details,
          variant: 'enabled',
          display_name: 'fantastic_split_with_information is on',
          description: 'This awesome feature makes cool stuff happen.'
        )
      end
      let!(:variant_detail_b) do
        FactoryBot.create(
          :variant_detail,
          split: split_with_details,
          variant: 'disabled',
          display_name: 'fantastic_split_with_information is off',
          description: 'This feature makes nothing happen.',
          screenshot: File.open(Rails.root.join('spec/support/uploads/ttlogo.png'))
        )
      end

      it "responds with details" do
        get "/api/v1/split_details/#{split_with_details.name}"

        expect(response_json).to include(
          "name" => split_with_details.name,
          "hypothesis" => split_with_details.hypothesis,
          "location" => split_with_details.location,
          "assignment_criteria" => split_with_details.assignment_criteria,
          "platform" => split_with_details.platform,
          "description" => split_with_details.description,
          "owner" => split_with_details.owner
        )

        expect(response_json['variant_details'][0]).to eq(
          "name" => "fantastic_split_with_information is on",
          "description" => 'This awesome feature makes cool stuff happen.'
        )

        expect(response_json['variant_details'][1]).to include(
          "name" => "fantastic_split_with_information is off",
          "description" => "This feature makes nothing happen."
        )

        expect(response_json['variant_details'][1]['screenshot_url']).to include 'ttlogo.png'
      end
    end

    it "blows up if split id is incorrect" do
      expect {
        get "/api/v1/split_details/i_am_not_a_real_split"
      }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
