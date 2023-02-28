require 'rails_helper'

RSpec.describe DeterministicAssignmentCreation do
  subject { DeterministicAssignmentCreation.new params }

  let(:visitor_id) { SecureRandom.uuid }

  let(:mixpanel_result) { "success" }
  let(:params) do
    {
      visitor_id: "bc8833fd-1bdc-4751-a13c-8aba0ef95a3b",
      split_name: "split",
      mixpanel_result: mixpanel_result,
      context: "the_context"
    }
  end

  let!(:split) { FactoryBot.create(:split, name: "split", registry: { variant1: 61, variant2: 1, variant3: 38 }) }

  describe "#initialize" do
    it "blows up when a variant is provided" do
      expect { described_class.new(variant: "not allowed!") }.to raise_error(/must not specify.*variant/)
    end
  end

  describe "#save!" do
    before do
      allow(ArbitraryAssignmentCreation).to receive(:create!).and_call_original
    end

    it "creates with the same visitor_id" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!)
        .with(hash_including(visitor_id: "bc8833fd-1bdc-4751-a13c-8aba0ef95a3b"))
    end

    it "creates with the same split name" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!)
        .with(hash_including(split_name: "split"))
    end

    it "creates with the same mixpanel result" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!)
        .with(hash_including(mixpanel_result: "success"))
    end

    it "creates with a calculated variant" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!)
        .with(hash_including(variant: "variant2"))
    end

    it "creates with the same context" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!)
        .with(hash_including(context: "the_context"))
    end

    context 'with an existing assignment' do
      let(:updated_at) { Time.zone.parse("2016-08-07 23:45:59") }
      let(:original_mixpanel_result) { "success" }

      let!(:existing_assignment) do
        assignment = FactoryBot.create(:assignment,
          split: split, variant: "variant3",
          visitor: Visitor.from_id("bc8833fd-1bdc-4751-a13c-8aba0ef95a3b"),
          mixpanel_result: original_mixpanel_result,
          updated_at: updated_at)

        assignment.reload
      end

      it "does not create a new assignment or change existing assignment" do
        original_attributes = existing_assignment.attributes

        subject.save!

        expect(ArbitraryAssignmentCreation).not_to have_received(:create!)
        expect(existing_assignment.reload.attributes).to eq original_attributes
      end

      context 'when the mixpanel result changes from failure to success' do
        let(:original_mixpanel_result) { "failure" }
        let(:mixpanel_result) { "success" }

        it "updates the new mixpanel_result but leaves existing updated_at" do
          subject.save!

          expect(ArbitraryAssignmentCreation).not_to have_received(:create!)
          expect(existing_assignment.reload.mixpanel_result).to eq "success"
          expect(existing_assignment.reload.updated_at).to eq Time.zone.parse("2016-08-07 23:45:59")
        end
      end

      context 'when the mixpanel result changes from nil to success' do
        let(:original_mixpanel_result) { nil }
        let(:mixpanel_result) { "success" }

        it "updates the new mixpanel_result but leaves existing updated_at" do
          subject.save!

          expect(ArbitraryAssignmentCreation).not_to have_received(:create!)
          expect(existing_assignment.reload.mixpanel_result).to eq "success"
          expect(existing_assignment.reload.updated_at).to eq Time.zone.parse("2016-08-07 23:45:59")
        end
      end

      context 'when the mixpanel result goes from success to failure' do
        let(:original_mixpanel_result) { "success" }
        let(:mixpanel_result) { "failure" }

        it "does not allow assignment to change" do
          original_attributes = existing_assignment.attributes

          subject.save!

          expect(ArbitraryAssignmentCreation).not_to have_received(:create!)
          expect(existing_assignment.reload.attributes).to eq original_attributes
        end
      end
    end

    context "with a feature gate" do
      let!(:split) do
        FactoryBot.create(:split, name: "split", registry: { variant1: 61, variant2: 1, variant3: 38 }, feature_gate: true)
      end

      it "skips creating for feature gates" do
        subject.save!

        expect(ArbitraryAssignmentCreation).not_to have_received(:create!)
      end
    end
  end

  describe "#variant_calculator" do
    it "is configured with the correct visitor_id" do
      expect(subject.variant_calculator.visitor_id).to eq "bc8833fd-1bdc-4751-a13c-8aba0ef95a3b"
    end

    it "is configured with the correct split" do
      expect(subject.variant_calculator.split.name).to eq "split"
    end

    it "calculates the right assignment bucket for the visitor_id and split_name" do
      expect(subject.variant_calculator.assignment_bucket).to eq 61
    end
  end
end
