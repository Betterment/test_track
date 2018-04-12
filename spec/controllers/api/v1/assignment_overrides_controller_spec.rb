require 'rails_helper'

RSpec.describe Api::V1::AssignmentOverridesController, type: :controller do
  describe "#create" do
    let!(:visitor) { FactoryBot.create :visitor }
    let(:split) { FactoryBot.create(:split, registry: { control: 50, treatment: 50 }) }

    let(:create_params) do
      {
        visitor_id: visitor.id,
        split_name: split.name,
        variant: "treatment",
        mixpanel_result: "success",
        context: "context"
      }
    end

    it "raises when there is no BROWSER_EXTENSION_SHARED_SECRET" do
      with_env BROWSER_EXTENSION_SHARED_SECRET: nil do
        expect {
          post :create, params: create_params
        }.to raise_error(/BROWSER_EXTENSION_SHARED_SECRET/)
      end
    end

    it "raises when there is an empty BROWSER_EXTENSION_SHARED_SECRET" do
      with_env BROWSER_EXTENSION_SHARED_SECRET: '' do
        expect {
          post :create, params: create_params
        }.to raise_error(/BROWSER_EXTENSION_SHARED_SECRET/)
      end
    end

    context "when configured with a BROWSER_EXTENSION_SHARED_SECRET" do
      around do |example|
        with_env BROWSER_EXTENSION_SHARED_SECRET: "the best password" do
          example.run
        end
      end

      context "when correctly authenticated" do
        before do
          http_authenticate username: "doesn't matter", auth_secret: "the best password"
        end

        it "creates an assignment if none already exists" do
          expect {
            post :create, params: create_params
          }.to change { Assignment.count }.by(1)

          expect(response).to have_http_status :no_content

          assignment = Assignment.first
          expect(assignment.variant).to eq "treatment"
          expect(assignment.visitor).to eq visitor
          expect(assignment.split).to eq split
          expect(assignment.mixpanel_result).to eq "success"
          expect(assignment.context).to eq "context"
        end

        it "overrides an assignment if one already exists" do
          FactoryBot.create(:assignment, visitor: visitor, split: split, variant: "control")

          expect {
            post :create, params: create_params
          }.to change { PreviousAssignment.count }.by(1)

          expect(response).to have_http_status :no_content
        end

        it "allows a request without a mixpanel_result" do
          post :create, params: create_params.except(:mixpanel_result)

          expect(response).to have_http_status :no_content

          assignment = Assignment.first
          expect(assignment.variant).to eq "treatment"
          expect(assignment.visitor).to eq visitor
          expect(assignment.split).to eq split
          expect(assignment.mixpanel_result).to eq nil
          expect(assignment.context).to eq "context"
        end
      end

      it "returns unauthorized and doesn't create an assignment with the wrong password" do
        http_authenticate username: "doesn't matter", auth_secret: "the worst password"
        expect {
          post :create, params: create_params
        }.not_to change { Assignment.count }

        expect(response).to have_http_status :unauthorized
      end

      it "returns unauthorized and doesn't create an assignment with no password" do
        expect {
          post :create, params: create_params
        }.not_to change { Assignment.count }

        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
