require 'rails_helper'

RSpec.describe BulkAssignmentCreation do
  let(:split) { FactoryBot.create :split, name: "crying_in_baseball", registry: { yes: 20, no: 80 } }
  let!(:identifier_type) { FactoryBot.create :identifier_type }

  let!(:visitor) { FactoryBot.create(:visitor) }
  let!(:identifier) { FactoryBot.create(:identifier, visitor: visitor, identifier_type_id: identifier_type.id, value: "22") }
  let!(:assignment) { FactoryBot.create(:assignment, visitor: visitor, split: split, variant: "yes", context: "original_context") }

  let(:admin) { FactoryBot.create :admin }

  let(:ids_csv) { ["22", "5092", "1bc12fa6-6c5b-47a4-b500-82b4e271520f"].join(',') }

  let(:create_params) do
    {
      identifiers_listing: ids_csv,
      identifier_type_id: identifier_type.id,
      variant: "no",
      reason: "because i felt like it",
      split: split,
      admin: admin,
      force_identifier_creation: '1'
    }
  end

  subject { described_class.new create_params }

  context "validates" do
    context "identifiers_listing" do
      def subject_with_csv_string(csv_string)
        described_class.new(create_params.merge(identifiers_listing: csv_string, reason: "just because"))
      end

      def expect_valid_and_is_1_2_3_4(csv_string)
        csv_bulk_assignment = subject_with_csv_string(csv_string)
        expect(csv_bulk_assignment.send(:ids_to_assign)).to match_array %w(1 2 3 4)
        expect(csv_bulk_assignment).to be_valid
      end

      it "allows newline or comma separated" do
        expect_valid_and_is_1_2_3_4("1\n 2\n 3\n 4")
        expect_valid_and_is_1_2_3_4(" 1, 2, 3, 4")
        expect_valid_and_is_1_2_3_4(" 1\t2\t 3\t\n4")
        expect_valid_and_is_1_2_3_4(" 1,2, \n\n\n\n3,\n4")
        expect_valid_and_is_1_2_3_4(
          "1\
           2\
           3\
           4"
        )
        expect_valid_and_is_1_2_3_4(
          "\
           1\
           2\
           3\
           4\
           "
        )
      end

      it "rejects blank" do
        expect(subject_with_csv_string("")).not_to be_valid
      end

      it "accepts lightly malformed csv" do
        expect(subject_with_csv_string("1,2,3,,")).to be_valid
      end

      it "allows arbitrary string identifiers" do
        bulk_assign_four = subject_with_csv_string("ab-cd-ef me@there.com 3445 sup_dude? hello.there@example.com")
        expect(bulk_assign_four).to be_valid
        expect(bulk_assign_four.send(:ids_to_assign)).to match_array %w(ab-cd-ef me@there.com 3445 sup_dude? hello.there@example.com)
      end

      it "allows numeric" do
        expect(subject_with_csv_string("1")).to be_valid
        expect(subject_with_csv_string("1,2,3,4")).to be_valid
        expect(subject_with_csv_string("1 2 3 4")).to be_valid
        expect(subject_with_csv_string("1\t2\t3\t6")).to be_valid
      end
    end

    def subject_with_reason(reason)
      described_class.new(create_params.merge(identifiers_listing: "1", reason: reason))
    end

    specify "reason is long enough and not blank" do
      expect(subject_with_reason("short")).to be_valid
      expect(subject_with_reason("thats the way we do it")).to be_valid

      expect(subject_with_reason(nil)).not_to be_valid
      expect(subject_with_reason("")).not_to be_valid
      expect(subject_with_reason("       ")).not_to be_valid
    end
  end

  it "parses CSV data to ids" do
    expect(subject.send(:ids_to_assign)).to match_array %w(5092 22 1bc12fa6-6c5b-47a4-b500-82b4e271520f)
  end

  describe "#save" do
    let(:current_assignment) { Assignment.find_by!(visitor: visitor, split: split) }

    it "saves the bulk assignment correctly" do
      subject.save
      bulk_assignment = subject.bulk_assignment.reload

      expect(bulk_assignment.variant).to eq "no"
      expect(bulk_assignment.split).to eq split
      expect(bulk_assignment.reason).to eq "because i felt like it"
      expect(bulk_assignment.admin).to eq admin
      expect(current_assignment.variant).to eq "no"
    end

    it "writes an epoch bulk_assignment linked to assignments" do
      expect { subject.save }
        .to change { Assignment.count }.by(2) # 3 "changed" but there are only 2 new ones
        .and change { PreviousAssignment.count }.by(1)
        .and change { BulkAssignment.count }.by(1)

      expect(Assignment.where(bulk_assignment: subject.bulk_assignment).count).to eq 3

      current_assignment = Assignment.find_by(visitor: visitor)
      previous_assignment = PreviousAssignment.find_by(assignment: current_assignment)

      expect(subject.bulk_assignment.variant).to eq current_assignment.variant
      expect(subject.bulk_assignment.split).to eq current_assignment.split

      expect(current_assignment.bulk_assignment).to eq subject.bulk_assignment
      expect(previous_assignment.bulk_assignment).not_to be_present
    end

    it "saves all or none" do
      bad_actor = instance_double(ArbitraryAssignmentCreation)
      allow(bad_actor).to receive(:save!).and_raise("too cool for school")
      subject.send(:assignment_creations) << bad_actor

      expect { subject.save }
        .to raise_error("too cool for school")
        .and change { Assignment.count }.by(0)
        .and change { BulkAssignment.count }.by(0)
    end

    it "overrides previous assignments" do
      expect { subject.save }
        .to change { Assignment.count }.by(2)
        .and change { PreviousAssignment.count }.by(1)
        .and change { BulkAssignment.count }.by(1)

      current_assignment = Assignment.find_by(visitor: visitor)
      previous_assignment = PreviousAssignment.find_by(assignment: current_assignment)

      expect(current_assignment.variant).to eq "no"
      expect(current_assignment.bulk_assignment).to be_present
      expect(current_assignment.context).to eq 'bulk_assignment'

      expect(previous_assignment.variant).to eq "yes"
      expect(previous_assignment.bulk_assignment).not_to be_present
      expect(previous_assignment.context).to eq 'original_context'
    end

    it "keeps bulk_assignment pointed to previous assignments" do
      no_bulk_assign = described_class.create(create_params.merge(identifiers_listing: "22", variant: "no")).bulk_assignment
      yes_bulk_assign = described_class.create(create_params.merge(identifiers_listing: "22", variant: "yes")).bulk_assignment

      current_assignment = Assignment.find_by(visitor: visitor)
      previous_assignments = PreviousAssignment.where(assignment: current_assignment).order(:created_at)

      expect(previous_assignments.count).to eq 2

      expect(current_assignment.bulk_assignment).to eq yes_bulk_assign
      expect(previous_assignments.find_by(variant: "no").bulk_assignment).to eq no_bulk_assign
      expect(previous_assignments.find_by(variant: "yes").bulk_assignment).to be_nil
    end

    it "assigns the specified population to the same variant" do
      bulk_assign_create = subject.tap(&:save)

      expect(bulk_assign_create.variant).to eq "no"
      expect(Assignment.all.map(&:variant).uniq).to match_array ["no"]
    end

    it "creates new Visitors and Identifiers for unidentified ids" do
      expect(Visitor.count).to eq 1
      expect(Identifier.count).to eq 1

      expect(Identifier.find_by(value: "5092")).to be_nil
      expect(Identifier.find_by(value: "1bc12fa6-6c5b-47a4-b500-82b4e271520f")).to be_nil

      expect { subject.save }
        .to change { Visitor.count }.by(2)
        .and change { Identifier.count }.by(2)
        .and change { BulkAssignment.count }.by(1)

      expect(Identifier.find_by(value: "5092")).to be_present
      expect(Identifier.find_by(value: "1bc12fa6-6c5b-47a4-b500-82b4e271520f")).to be_present
    end

    it "idempotently creates assignments" do
      expect { subject.save }.to change { Assignment.count }.by(2).and change { BulkAssignment.count }.by(1)
      expect { subject.save }.to change { Assignment.count }.by(0).and change { BulkAssignment.count }.by(0)
    end

    it "creates assignments for new Visitors with 'bulk_assignment' context" do
      subject.save
      bulk_assignment = subject.bulk_assignment.reload

      Identifier.find_by(value: "5092").tap do |identifier|
        expect(identifier.visitor.assignments.count).to eq 1

        assignment = identifier.visitor.assignments.first!
        expect(assignment.split).to eq split
        expect(assignment.variant).to eq "no"
        expect(assignment.bulk_assignment).to eq bulk_assignment
        expect(assignment.context).to eq "bulk_assignment"
      end

      Identifier.find_by(value: "1bc12fa6-6c5b-47a4-b500-82b4e271520f").tap do |identifier|
        expect(identifier.visitor.assignments.count).to eq 1

        assignment = identifier.visitor.assignments.first!
        expect(assignment.split).to eq split
        expect(assignment.variant).to eq "no"
        expect(assignment.bulk_assignment).to eq bulk_assignment
        expect(assignment.context).to eq "bulk_assignment"
      end
    end
  end

  context "individually_overridden" do
    specify "bulk override without a dirty flag doesn't set it" do
      subject.save

      current_assignment = Assignment.find_by(visitor: visitor)
      previous_assignment = current_assignment.previous_assignments.first

      expect(current_assignment.individually_overridden).to be false
      expect(previous_assignment.individually_overridden).to be false
    end

    it "maintains the individually_overridden dirty flag across bulk assignments" do
      assignment.update(individually_overridden: true, context: "individually_overridden")

      subject.save

      current_assignment = Assignment.find_by(visitor: visitor)
      previous_assignment = current_assignment.previous_assignments.first

      expect(current_assignment.individually_overridden).to be true
      expect(current_assignment.context).to eq "bulk_assignment"
      expect(previous_assignment.individually_overridden).to be true
      expect(previous_assignment.context).to eq "individually_overridden"
    end
  end

  describe "#new_identifier_creation_ratio" do
    it "calculates identifier creation percentage" do
      expect(subject.send(:new_identifier_creation_ratio)).to be_within(0.01).of(0.67)
    end

    it "responds with 0 if there are no ids to assign" do
      expect(described_class.new.send(:new_identifier_creation_ratio)).to eq 0
    end
  end
end
