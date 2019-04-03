require 'rails_helper'

RSpec.describe BulkReassignment do
  let(:visitor_supersession) { FactoryBot.create(:visitor_supersession) }
  let(:old_bulk_assignment) { FactoryBot.create(:bulk_assignment) }
  let(:split) { FactoryBot.create(:split, registry: { foo: 50, bar: 50 }) }
  let(:assignment_attrs) do
    {
      split: split,
      variant: :foo,
      mixpanel_result: "success",
      context: "original_context",
      individually_overridden: true,
      visitor_supersession: visitor_supersession,
      bulk_assignment: old_bulk_assignment,
      created_at: 7.minutes.ago,
      updated_at: 7.minutes.ago
    }
  end
  let!(:assignments) { FactoryBot.create_list(:assignment, 2, assignment_attrs) }
  let(:assignment) { assignments.first }
  let!(:other_assignment) { FactoryBot.create(:assignment, assignment_attrs) }
  let(:bulk_assignment) { FactoryBot.create(:bulk_assignment, split: split, variant: :bar, created_at: 5.minutes.ago) }
  let!(:old_updated_at) { assignment.updated_at }

  it "reassigns multiple chosen assignments based on relation" do
    bulk_reassignment = described_class.new(assignments: Assignment.where(id: assignments.map(&:id)), bulk_assignment: bulk_assignment)

    expect(bulk_reassignment.save).to eq true

    expect(assignments.length).to eq 2
    expect(assignments.first.reload.variant).to eq "bar"
    expect(assignments.last.reload.variant).to eq "bar"

    other_assignment.reload
    expect(other_assignment.variant).to eq "foo"
    expect(other_assignment.previous_assignments).not_to be_present
  end

  it "reassigns multiple chosen assignments to bar based on array" do
    bulk_reassignment = described_class.new(assignments: assignments, bulk_assignment: bulk_assignment)

    expect(bulk_reassignment.save).to eq true

    expect(assignments.length).to eq 2
    expect(assignments.first.reload.variant).to eq "bar"
    expect(assignments.last.reload.variant).to eq "bar"

    other_assignment.reload
    expect(other_assignment.variant).to eq "foo"
    expect(other_assignment.previous_assignments).not_to be_present
  end

  it "reassigns nothing with an empty array" do
    bulk_reassignment = described_class.new(assignments: [], bulk_assignment: bulk_assignment)

    expect(bulk_reassignment.save).to eq true

    expect(Assignment.where(variant: "bar")).not_to be_present
  end

  context "when updating one assignment" do
    subject! { described_class.create!(assignments: [assignment], bulk_assignment: bulk_assignment) }

    before do
      assignment.reload
    end

    it "stores a reference to the bulk assignment in the assignment record" do
      expect(assignment.bulk_assignment_id).to eq bulk_assignment.id
    end

    it "sets mixpanel_result to nil on affected rows" do
      expect(assignment.mixpanel_result).to eq nil
    end

    it "preserves individually_overridden" do
      expect(assignment.individually_overridden).to eq true
    end

    it "uses bulk_assignment's created_at as updated_at" do
      expect(assignment.updated_at).to be_within(0.1.seconds).of(bulk_assignment.created_at)
    end

    it "sets context to 'bulk_assignment'" do
      expect(assignment.context).to eq "bulk_assignment"
    end

    it "does not set a visitor supersession" do
      expect(assignment.visitor_supersession).to eq nil
    end

    it "creates a previous_assignment record" do
      expect(assignment.previous_assignments.length).to eq 1
    end

    context "within the created previous_assignment record" do
      let(:previous_assignment) { assignment.previous_assignments.first }

      it "preserves old variant" do
        expect(previous_assignment.variant).to eq "foo"
      end

      it "preserves old bulk_assignment_id" do
        expect(previous_assignment.bulk_assignment_id).to eq old_bulk_assignment.id
      end

      it "preserves old updated_at as created_at" do
        expect(previous_assignment.created_at).to be_within(0.1.seconds).of(old_updated_at)
      end

      it "uses bulk_assignment's creation as superseded_at" do
        expect(previous_assignment.superseded_at).to be_within(0.1.seconds).of(bulk_assignment.created_at)
      end

      it "preserves old individually_overridden" do
        expect(previous_assignment.individually_overridden).to eq true
      end

      it "preserves old context" do
        expect(previous_assignment.context).to eq "original_context"
      end

      it "preserves old visitor_supersession_id" do
        expect(previous_assignment.visitor_supersession_id).to eq visitor_supersession.id
      end
    end
  end
end
