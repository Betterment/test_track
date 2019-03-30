require 'rails_helper'

RSpec.describe Api::V1::VisitorsController, type: :controller do
  describe "#show" do
    let(:visitor) { FactoryBot.create :visitor }

    let(:split_1) { FactoryBot.create(:split, name: "one", registry: { "control": 50, "treatment": 50 }) }
    let(:split_2) { FactoryBot.create(:split, name: "two", registry: { "control": 50, "treatment": 50 }) }

    let(:allow_signup) { FactoryBot.create(:split, name: "allow_signup", registry: { true: 50, false: 50 }) }

    context "with multiple assignments" do
      before do
        FactoryBot.create(:assignment,
          visitor: visitor,
          split: split_1,
          variant: "control",
          context: "context_a",
          mixpanel_result: "success")
        FactoryBot.create(:assignment,
          visitor: visitor,
          split: split_2,
          variant: "treatment",
          context: "context_b",
          mixpanel_result: "success")
        FactoryBot.create(:assignment,
          visitor: visitor,
          split: allow_signup,
          variant: :true,
          context: "context_c",
          mixpanel_result: "failure")
      end

      it "responds with all assigned variants" do
        get :show, params: { id: visitor.id }

        expect(response).to have_http_status :ok
        expect(response_json["id"]).to eq(visitor.id)
        expect(response_json["assignments"].length).to eq 3
        expect(response_json["assignments"]).to include(
          hash_including(
            "split_name" => "one",
            "variant" => "control",
            "unsynced" => false,
            "context" => "context_a"
          )
        )
        expect(response_json["assignments"]).to include(
          hash_including(
            "split_name" => "two",
            "variant" => "treatment",
            "unsynced" => false,
            "context" => "context_b"
          )
        )
        expect(response_json["assignments"]).to include(
          hash_including(
            "split_name" => "allow_signup",
            "variant" => "true",
            "unsynced" => true,
            "context" => "context_c"
          )
        )
      end

      it "only queries twice (visitors, then assignments joined to splits)" do
        expect { get :show, params: { id: visitor.id } }.to make_database_queries(count: 2)
      end
    end

    it "responds with empty assignments if visitor has no assignments" do
      get :show, params: { id: visitor.id }
      expect(response).to have_http_status :ok
      expect(response_json).to eq(
        "id" => visitor.id,
        "assignments" => []
      )
    end

    it "echoes back the provided visitor id if visitor doesn't exist" do
      get :show, params: { id: "ffffffff-ffff-ffff-ffff-ffffffffffff" }

      expect(response).to have_http_status :ok
      expect(response_json).to eq(
        "id" => "ffffffff-ffff-ffff-ffff-ffffffffffff",
        "assignments" => []
      )
    end
  end
end
