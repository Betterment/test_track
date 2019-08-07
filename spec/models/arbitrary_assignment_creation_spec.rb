require 'rails_helper'

RSpec.describe ArbitraryAssignmentCreation, type: :model do
  subject { ArbitraryAssignmentCreation.new params }

  let(:updated_at) { nil }
  let(:params) do
    {
      visitor_id: SecureRandom.uuid,
      split_name: "split",
      variant: "variant1",
      mixpanel_result: "success",
      context: "the_context",
      updated_at: updated_at
    }
  end

  let!(:split) { FactoryBot.create(:split, name: "split", registry: { variant1: 50, variant2: 50 }) }

  describe "#save!" do
    it "creates a new visitor record if none already exists" do
      expect { subject.save! }
        .to change { Visitor.count }.by(1)

      visitor = Visitor.first
      expect(visitor.id).to eq params[:visitor_id]
    end

    it "finds existing visitor when there is a visitor creation race condition" do
      visitor = FactoryBot.create(:visitor, id: params[:visitor_id])
      error = ActiveRecord::RecordNotUnique.new("duplicate key value violates unique constraint")
      allow(Visitor).to receive(:find_or_create_by!).and_raise(error)

      expect { subject.save! }
        .to change { Visitor.count }.by(0)
        .and change { Assignment.count }.by(1)

      assignment = Assignment.first
      expect(assignment.visitor).to eq visitor
    end

    it "creates an assignment if none already exists" do
      visitor = FactoryBot.create(:visitor, id: params[:visitor_id])

      expect { subject.save! }
        .to change { Assignment.count }.by(1)

      assignment = Assignment.first
      expect(assignment.variant).to eq "variant1"
      expect(assignment.visitor).to eq visitor
      expect(assignment.split).to eq split
      expect(assignment.mixpanel_result).to eq "success"
      expect(assignment.context).to eq "the_context"
      expect(assignment.bulk_assignment).not_to be_present
      expect(assignment).not_to be_individually_overridden
    end

    context "assignment already has requested variant" do
      let(:visitor) { FactoryBot.create(:visitor, id: params[:visitor_id]) }

      context "bulk assigned assignment" do
        let(:bulk_assignment) { FactoryBot.create(:bulk_assignment, split: split, variant: "variant1") }
        let!(:existing_assignment) do
          FactoryBot.create(
            :assignment,
            visitor: visitor,
            split: split,
            variant: "variant1",
            bulk_assignment: bulk_assignment,
            context: "bulk_assignment",
            mixpanel_result: "success",
            updated_at: Time.zone.parse('2019-01-01 00:00:00')
          )
        end

        it "maintains bulk assignment status" do
          expect { subject.save! }
            .not_to change { Assignment.count }

          existing_assignment.reload
          expect(existing_assignment.variant).to eq "variant1"
          expect(existing_assignment.visitor).to eq visitor
          expect(existing_assignment.split).to eq split
          expect(existing_assignment.bulk_assignment).to eq bulk_assignment
          expect(existing_assignment.context).to eq "bulk_assignment"
        end
      end

      context "organic assignment" do
        let!(:existing_assignment) do
          FactoryBot.create(
            :assignment,
            visitor: visitor,
            split: split,
            variant: "variant1",
            context: "context",
            mixpanel_result: "success",
            updated_at: Time.zone.parse('2019-01-01 00:00:00')
          )
        end

        it "touches the record but changes nothing else" do
          Timecop.freeze(Time.zone.parse('2019-07-01 00:00:00')) do
            expect { subject.save! }
              .not_to change { Assignment.count }
          end

          existing_assignment.reload
          expect(existing_assignment.variant).to eq "variant1"
          expect(existing_assignment.visitor).to eq visitor
          expect(existing_assignment.split).to eq split
          expect(existing_assignment.bulk_assignment).to eq nil
          expect(existing_assignment.context).to eq "context"
          expect(existing_assignment.mixpanel_result).to eq "success"
          expect(existing_assignment.updated_at).to eq Time.zone.parse('2019-07-01 00:00:00')
        end
      end
    end

    it "saves again and overwrites nil mixpanel result when there is a race condition with the same variant" do
      visitor = FactoryBot.create(:visitor, id: params[:visitor_id])
      assignment = Assignment.new(visitor: visitor, split: split)
      allow(Assignment).to receive(:find_or_initialize_by).and_return(assignment)
      allow(assignment).to receive(:save!) do
        # simulate race condition
        FactoryBot.create(:assignment, visitor: visitor, split: split, variant: "variant1", mixpanel_result: nil)
        allow(Assignment).to receive(:find_or_initialize_by).and_call_original
        raise ActiveRecord::RecordNotUnique, "duplicate key value violates unique constraint"
      end

      expect { subject.save! }
        .to change { Assignment.count }.by(1)
        .and change { PreviousAssignment.count }.by(0)

      assignment = Assignment.first
      expect(assignment.mixpanel_result).to eq "success"
    end

    it "supersedes when there is a race condition with a different variant" do
      visitor = FactoryBot.create(:visitor, id: params[:visitor_id])
      assignment = Assignment.new(visitor: visitor, split: split)
      allow(Assignment).to receive(:find_or_initialize_by).and_return(assignment)
      allow(assignment).to receive(:save!) do
        # simulate race condition
        FactoryBot.create(:assignment, visitor: visitor, split: split, variant: "variant2")
        allow(Assignment).to receive(:find_or_initialize_by).and_call_original
        raise ActiveRecord::RecordNotUnique, "duplicate key value violates unique constraint"
      end

      expect { subject.save! }
        .to change { Assignment.count }.by(1)
        .and change { PreviousAssignment.count }.by(1)

      assignment = Assignment.first
      expect(assignment.variant).to eq "variant1"
    end

    context "mixpanel_result" do
      let(:updated_at) { Date.parse("2016-08-07") }
      let(:assignment_creation_without_mixpanel_result) { ArbitraryAssignmentCreation.new params.except(:mixpanel_result) }
      let(:assignment_creation_with_mixpanel_result) { subject }

      it "sets the mixpanel_result to nil if it's not provided" do
        assignment_creation_without_mixpanel_result.save!

        assignment = Assignment.first
        expect(assignment.mixpanel_result).to eq nil
      end

      it "does not override an existing assignment's mixpanel_result with nil mixpanel_result" do
        visitor = FactoryBot.create(:visitor, id: params[:visitor_id])
        existing_assignment = FactoryBot.create(
          :assignment,
          visitor: visitor,
          split: split,
          variant: "variant1",
          mixpanel_result: "success"
        )

        assignment_creation_without_mixpanel_result.save!

        existing_assignment.reload
        expect(existing_assignment.mixpanel_result).to eq "success"
      end

      it "overrides an existing assignment's mixpanel_result with a non-nil mixpanel_result and keeps the original updated_at" do
        visitor = FactoryBot.create(:visitor, id: params[:visitor_id])
        existing_assignment = FactoryBot.create(
          :assignment,
          visitor: visitor,
          split: split,
          variant: "variant1",
          mixpanel_result: nil
        )

        assignment_creation_with_mixpanel_result.save!

        existing_assignment.reload
        expect(existing_assignment.mixpanel_result).to eq "success"
        expect(existing_assignment.updated_at).to eq Date.parse("2016-08-07")
      end

      it "overrides an existing assignment's mixpanel_result when switching variants" do
        visitor = FactoryBot.create(:visitor, id: params[:visitor_id])
        existing_assignment = FactoryBot.create(
          :assignment,
          visitor: visitor,
          split: split,
          variant: "variant2",
          mixpanel_result: nil
        )

        assignment_creation_with_mixpanel_result.save!

        existing_assignment.reload
        expect(existing_assignment.mixpanel_result).to eq "success"
      end
    end

    context "individually_overridden" do
      let(:visitor) { FactoryBot.create(:visitor, id: params[:visitor_id]) }
      let(:existing_assignment_params) { { visitor: visitor, split: split, variant: "variant2", individually_overridden: false } }

      it "is true if an assignment already exists" do
        existing_assignment = FactoryBot.create(:assignment, existing_assignment_params)

        expect { subject.save! }
          .to change { PreviousAssignment.count }.by(1)

        expect(existing_assignment.reload.variant).to eq "variant1"
        existing_assignment.previous_assignments.first.tap do |prev|
          expect(prev.variant).to eq "variant2"
          expect(existing_assignment).to be_individually_overridden
          expect(existing_assignment.bulk_assignment).to eq nil
          expect(existing_assignment.updated_at).to eq prev.superseded_at
          expect(existing_assignment.context).to eq "individually_overridden"
        end
      end

      it "remains during a bulk assignment" do
        existing_assignment = FactoryBot.create(:assignment, existing_assignment_params.merge(individually_overridden: true))
        bulk_assignment = FactoryBot.create(:bulk_assignment, split: existing_assignment_params[:split])

        ArbitraryAssignmentCreation.create!(params.merge(bulk_assignment_id: bulk_assignment.id))

        expect(existing_assignment.reload.bulk_assignment).to eq bulk_assignment
        expect(existing_assignment).to be_individually_overridden
        expect(existing_assignment.context).to eq "individually_overridden"
      end

      it "makes a previous bulk_assignment nil" do
        bulk_assignment = FactoryBot.create(:bulk_assignment, split: existing_assignment_params[:split])
        existing_assignment = FactoryBot.create(:assignment, existing_assignment_params.merge(bulk_assignment_id: bulk_assignment.id))

        expect(existing_assignment.bulk_assignment).to eq bulk_assignment

        subject.save!

        expect(existing_assignment.reload.bulk_assignment).to eq nil
        expect(existing_assignment).to be_individually_overridden
        expect(existing_assignment.context).to eq "individually_overridden"
      end
    end
  end

  describe ".create!" do
    it "returns the created instance" do
      assignment_creation = ArbitraryAssignmentCreation.create! params
      expect(assignment_creation).to be_a(ArbitraryAssignmentCreation)
    end
  end
end
