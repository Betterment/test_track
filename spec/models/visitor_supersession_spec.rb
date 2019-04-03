require 'rails_helper'

RSpec.describe VisitorSupersession do
  let(:visitor) { FactoryBot.create(:visitor) }

  let(:existing_identifier) { FactoryBot.create(:identifier) }
  let(:existing_visitor) { existing_identifier.visitor }

  let(:banana_split) { FactoryBot.create(:split, name: :banana, registry: { green: 50, squishy: 50 }) }
  let(:torque_split) { FactoryBot.create(:split, name: :torque, registry: { front: 40, rear: 60 }) }

  describe "#save!" do
    before do
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
      FactoryBot.create(:assignment,
        visitor: visitor,
        split: torque_split,
        variant: "rear",
        mixpanel_result: "success",
        context: "context3")
    end

    it "merges assignments from the superseded visitor without overwriting existing assignments" do
      visitor_supersession = described_class.create!(superseded_visitor: visitor, superseding_visitor: existing_visitor)

      banana_split_assignment = existing_visitor.assignments.find_by!(split: banana_split, variant: "squishy")
      expect(banana_split_assignment.mixpanel_result).to eq "success"
      expect(banana_split_assignment.visitor_supersession).to eq nil
      expect(banana_split_assignment.context).to eq "context2"

      torque_split_assignment = existing_visitor.assignments.find_by!(split: torque_split, variant: "rear")
      expect(torque_split_assignment.mixpanel_result).to eq nil
      expect(torque_split_assignment.visitor_supersession).to eq visitor_supersession
      expect(torque_split_assignment.context).to eq "visitor_supersession"
    end
  end
end
