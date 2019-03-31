require 'rails_helper'

RSpec.describe Decision do
  let(:split) { FactoryBot.create(:split, registry: { treatment: 90, disease: 10 }) }
  subject { split.build_decision }

  describe "#save!" do
    it "persists as a weighting, a decision and decided_at value" do
      t = Time.zone.parse("2011-01-01 00:00:00")
      Timecop.freeze(t) do
        subject.variant = :treatment
        subject.save!

        expect(split.registry).to eq("treatment" => 100, "disease" => 0)
        expect(split.decision).to eq "treatment"
        expect(split.decided_at).to eq t
      end
    end

    it "won't allow an invalid decision variant" do
      subject.variant = :invalid_variant
      expect { subject.save! }.to raise_error(/Decision must be a variant of the split/)
    end
  end
end
