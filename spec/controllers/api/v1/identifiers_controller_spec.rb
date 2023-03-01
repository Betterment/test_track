require 'rails_helper'

RSpec.describe Api::V1::IdentifiersController do
  describe "#create" do
    let(:visitor) { FactoryBot.create(:visitor) }
    let(:identifier_type) { FactoryBot.create(:identifier_type) }

    let(:banana_split) { FactoryBot.create(:split, name: :banana, registry: { green: 50, squishy: 50 }) }

    it "responds with assigned variants for the visitor" do
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: banana_split,
        variant: "green",
        context: "the_context",
        mixpanel_result: "success")

      post :create, params: { visitor_id: visitor.id, identifier_type: identifier_type.name, value: "123" }

      response_json['visitor'].tap do |visitor_json|
        expect(visitor_json['id']).to eq visitor.id
        expect(visitor_json['assignments'][0]['split_name']).to eq('banana')
        expect(visitor_json['assignments'][0]['variant']).to eq('green')
        expect(visitor_json['assignments'][0]['unsynced']).to be(false)
        expect(visitor_json['assignments'][0]['context']).to eq('the_context')
      end
    end

    it "responds with mixpanel_failure_assignments for copied assignments" do
      existing_visitor = FactoryBot.create(:visitor)
      FactoryBot.create(:identifier, identifier_type: identifier_type, value: "123", visitor: existing_visitor)
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: banana_split,
        variant: "green",
        context: "the_context",
        mixpanel_result: "success")

      post :create, params: { visitor_id: visitor.id, identifier_type: identifier_type.name, value: "123" }

      response_json['visitor'].tap do |visitor_json|
        expect(visitor_json['id']).to eq existing_visitor.id
        expect(visitor_json['assignments'][0]['split_name']).to eq('banana')
        expect(visitor_json['assignments'][0]['variant']).to eq('green')
        expect(visitor_json['assignments'][0]['unsynced']).to be(true)
        expect(visitor_json['assignments'][0]['context']).to eq('visitor_supersession')
      end
    end

    it "responds with an error if given an invalid identifier_type" do
      post :create, params: { visitor_id: visitor.id, identifier_type: "Foobaloo", value: "123" }

      expect(response).to have_http_status :unprocessable_entity
      expect(response_json).to eq(
        "errors" => { "identifier_type" => ["does not exist"] }
      )
    end
  end
end
