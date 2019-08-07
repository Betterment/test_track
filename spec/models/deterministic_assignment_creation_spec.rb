require 'rails_helper'

RSpec.describe DeterministicAssignmentCreation, type: :model do
  subject { DeterministicAssignmentCreation.new params }

  let(:visitor_id) { SecureRandom.uuid }

  let(:params) do
    {
      visitor_id: "bc8833fd-1bdc-4751-a13c-8aba0ef95a3b",
      split_name: "split",
      mixpanel_result: "success",
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

    context 'with and existing assignement' do
      context 'when the mixpanel result is identical' do
        it "does not update the assignment" do
          FactoryBot.create(:assignment,
            split: split, variant: "variant3", mixpanel_result: "success",
            visitor: Visitor.from_id("bc8833fd-1bdc-4751-a13c-8aba0ef95a3b"))

          subject.save!

          expect(ArbitraryAssignmentCreation).not_to have_received(:create!)
        end
      end

      context 'when the mixpanel result is different' do
        let(:date) { Date.parse('2016-08-07') }

        it "passes the new mixpanel_result and existing updated_at" do
          FactoryBot.create(:assignment,
            split: split, variant: "variant3", mixpanel_result: nil,
            visitor: Visitor.from_id("bc8833fd-1bdc-4751-a13c-8aba0ef95a3b"), updated_at: date)

          subject.save!

          expect(ArbitraryAssignmentCreation).to have_received(:create!).with hash_including(
            mixpanel_result: "success", updated_at: Date.parse('2016-08-07')
          )
        end
      end
    end

    it "creates with the same context" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!)
        .with(hash_including(context: "the_context"))
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
