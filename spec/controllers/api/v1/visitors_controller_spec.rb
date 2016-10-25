require 'rails_helper'

RSpec.describe Api::V1::VisitorsController, type: :controller do
  describe "#show" do
    let(:visitor) { FactoryGirl.create :visitor }

    let(:split_1) { FactoryGirl.create(:split, name: "one", registry: { "control": 50, "treatment": 50 }) }
    let(:split_2) { FactoryGirl.create(:split, name: "two", registry: { "control": 50, "treatment": 50 }) }

    let(:allow_signup) { FactoryGirl.create(:split, name: "allow_signup", registry: { true: 50, false: 50 }) }

    context "with multiple assignments" do
      before do
        FactoryGirl.create(:assignment,
          visitor: visitor,
          split: split_1,
          variant: "control",
          context: "context_a",
          mixpanel_result: "success")
        FactoryGirl.create(:assignment,
          visitor: visitor,
          split: split_2,
          variant: "treatment",
          context: "context_b",
          mixpanel_result: "success")
        FactoryGirl.create(:assignment,
          visitor: visitor,
          split: allow_signup,
          variant: :true,
          context: "context_c",
          mixpanel_result: "failure")
      end

      it "responds with all assigned variants" do
        get :show, id: visitor.id

        expect(response).to have_http_status :ok
        expect(response_json["id"]).to eq(visitor.id)
        expect(response_json["assignments"][0]["split_name"]).to eq("one")
        expect(response_json["assignments"][0]["variant"]).to eq("control")
        expect(response_json["assignments"][0]["unsynced"]).to eq(false)
        expect(response_json["assignments"][0]["context"]).to eq("context_a")
        expect(response_json["assignments"][1]["split_name"]).to eq("two")
        expect(response_json["assignments"][1]["variant"]).to eq("treatment")
        expect(response_json["assignments"][1]["unsynced"]).to eq(false)
        expect(response_json["assignments"][1]["context"]).to eq("context_b")
        expect(response_json["assignments"][2]["split_name"]).to eq("allow_signup")
        expect(response_json["assignments"][2]["variant"]).to eq("true")
        expect(response_json["assignments"][2]["unsynced"]).to eq(true)
        expect(response_json["assignments"][2]["context"]).to eq("context_c")
      end

      it "only queries once per table (visitor, assignment, and split)" do
        expect { get :show, id: visitor.id }.to make_database_queries(count: 3)
      end
    end

    it "responds with empty assignments if visitor has no assignments" do
      get :show, id: visitor.id
      expect(response).to have_http_status :ok
      expect(response_json).to eq(
        "id" => visitor.id,
        "assignments" => []
      )
    end

    it "echoes back the provided visitor id if visitor doesn't exist" do
      get :show, id: "ffffffff-ffff-ffff-ffff-ffffffffffff"

      expect(response).to have_http_status :ok
      expect(response_json).to eq(
        "id" => "ffffffff-ffff-ffff-ffff-ffffffffffff",
        "assignments" => []
      )
    end
  end
end
