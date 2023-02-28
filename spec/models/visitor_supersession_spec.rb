require 'rails_helper'

RSpec.describe VisitorSupersession do
  let(:visitor) { FactoryBot.create(:visitor) }

  let(:existing_identifier) { FactoryBot.create(:identifier) }
  let(:existing_visitor) { existing_identifier.visitor }

  let(:banana_split) { FactoryBot.create(:split, name: :banana, registry: { green: 50, squishy: 50 }) }
  let(:torque_split) { FactoryBot.create(:split, name: :torque, registry: { front: 40, rear: 60 }) }
  let(:decided_split) { FactoryBot.create(:split, name: :decided, registry: { bad_thing: 50, good_thing: 50 }) }
  let(:feature_gate) { FactoryBot.create(:feature_gate) }

  describe "#save!" do
    it "doesn't merge feature gate assignments to ensure nobody piggybacks on a privileged identity to get into a closed feature gate" do
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: feature_gate,
        variant: "true",
        mixpanel_result: "success",
        context: "context5")

      described_class.create!(superseded_visitor: visitor, superseding_visitor: existing_visitor)

      expect(Assignment.where(visitor: visitor, split: feature_gate)).to be_present
      expect(Assignment.where(visitor: existing_visitor, split: feature_gate)).not_to be_present
    end

    it "merges non-decided non-feature-gates to attempt to preserve user experience of experiments that span signup/auth" do
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: torque_split,
        variant: "rear",
        mixpanel_result: "success",
        context: "context3")

      visitor_supersession = described_class.create!(superseded_visitor: visitor, superseding_visitor: existing_visitor)

      torque_split_assignment = existing_visitor.assignments.find_by!(split: torque_split, variant: "rear")
      expect(torque_split_assignment.mixpanel_result).to be_nil
      expect(torque_split_assignment.visitor_supersession).to eq visitor_supersession
      expect(torque_split_assignment.context).to eq "visitor_supersession"
    end

    it "doesn't merge decided non-feature-gates in a way that overrides the decision" do
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: decided_split,
        variant: "bad_thing",
        mixpanel_result: "success",
        context: "context4")
      decided_split.create_decision!(variant: "good_thing")

      described_class.create!(superseded_visitor: visitor, superseding_visitor: existing_visitor)

      expect(Assignment.for_presentation.where(visitor: visitor, split: decided_split)).not_to be_present
      expect(Assignment.where(visitor: visitor, split: decided_split)).to be_present

      expect(Assignment.for_presentation.where(visitor: existing_visitor, split: decided_split)).not_to be_present
      # expect(Assignment.where(visitor: existing_visitor, split: decided_split)).to HAVE_AS_YET_UNDEFINED_BEHAVIOR
    end

    it "doesn't merge assignments that already exist on the target visitor" do
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: banana_split,
        variant: "green",
        context: "context1")
      FactoryBot.create(:assignment,
        visitor: existing_visitor,
        split: banana_split,
        variant: "squishy",
        mixpanel_result: "success",
        context: "context2")

      described_class.create!(superseded_visitor: visitor, superseding_visitor: existing_visitor)

      banana_split_assignment = existing_visitor.assignments.find_by!(split: banana_split, variant: "squishy")
      expect(banana_split_assignment.mixpanel_result).to eq "success"
      expect(banana_split_assignment.visitor_supersession).to be_nil
      expect(banana_split_assignment.context).to eq "context2"
    end
  end
end
