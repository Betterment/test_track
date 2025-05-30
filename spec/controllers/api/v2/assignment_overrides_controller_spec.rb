require 'rails_helper'

RSpec.describe Api::V2::AssignmentOverridesController do
  describe "#create" do
    let!(:visitor) { FactoryBot.create(:visitor) }
    let(:split) { FactoryBot.create(:split, name: "1split", registry: { control: 50, treatment: 50 }) }

    let(:create_params) do
      {
        visitor_id: visitor.id,
        assignments: [
          {
            split_name: split.name,
            variant: "treatment",
            context: "context"
          }
        ]
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
          expect(assignment.force).to be true
        end

        it "overrides an assignment if one already exists" do
          FactoryBot.create(:assignment, visitor:, split:, variant: "control")

          expect {
            post :create, params: create_params
          }.to change { PreviousAssignment.count }.by(1)

          expect(Assignment.last.force).to be true
          expect(PreviousAssignment.last.force).to be false
          expect(response).to have_http_status :no_content
        end

        context "with multiple assignments in the payload" do
          let(:split2) { FactoryBot.create(:split, name: "2split", registry: { control: 50, treatment: 50 }) }

          let(:create_params) do
            {
              visitor_id: visitor.id,
              assignments: [
                {
                  split_name: split.name,
                  variant: "treatment",
                  context: "context"
                },
                {
                  split_name: split2.name,
                  variant: "treatment",
                  context: "context"
                }
              ]
            }
          end

          it "creates an assignment for each" do
            expect {
              post :create, params: create_params
            }.to change { Assignment.count }.by(2)

            expect(response).to have_http_status :no_content

            assignment = Assignment.joins(:split).merge(Split.order(name: :asc)).first
            expect(assignment.variant).to eq "treatment"
            expect(assignment.visitor).to eq visitor
            expect(assignment.split).to eq split
            expect(assignment.mixpanel_result).to eq "success"
            expect(assignment.context).to eq "context"
            expect(assignment.force).to be true

            assignment = Assignment.joins(:split).merge(Split.order(name: :asc)).second
            expect(assignment.variant).to eq "treatment"
            expect(assignment.visitor).to eq visitor
            expect(assignment.split).to eq split2
            expect(assignment.mixpanel_result).to eq "success"
            expect(assignment.context).to eq "context"
            expect(assignment.force).to be true
          end
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
