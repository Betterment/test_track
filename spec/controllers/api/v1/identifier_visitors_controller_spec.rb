require 'rails_helper'

RSpec.describe Api::V1::IdentifierVisitorsController do
  describe "#show" do
    let(:identifier_type) { FactoryBot.create(:identifier_type, name: "clown_id") }
    let(:split) { FactoryBot.create(:split, name: "what_time_is_it") }
    let(:assignment) do
      FactoryBot.create(:assignment, split: split, variant: :hammer_time, context: "the_context", mixpanel_result: "success")
    end
    let!(:identifier) { FactoryBot.create(:identifier, identifier_type: identifier_type, value: "1234", visitor: assignment.visitor) }

    it "responds with a visitor" do
      get :show, params: { identifier_type_name: "clown_id", identifier_value: "1234" }

      expect(response).to have_http_status :ok
      expect(response_json['id']).to eq assignment.visitor.id
      expect(response_json['assignments'][0]['split_name']).to eq('what_time_is_it')
      expect(response_json['assignments'][0]['variant']).to eq('hammer_time')
      expect(response_json['assignments'][0]['unsynced']).to be(false)
      expect(response_json['assignments'][0]['context']).to eq("the_context")
    end

    it "responds with an empty assignments list for visitor with no assignments" do
      identifier = FactoryBot.create(:identifier, identifier_type: identifier_type, value: "5678")

      get :show, params: { identifier_type_name: "clown_id", identifier_value: "5678" }

      expect(response).to have_http_status :ok
      expect(response_json['id']).to eq identifier.visitor.id
      expect(response_json['assignments']).to eq([])
    end
  end
end
