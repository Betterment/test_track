require 'rails_helper'

RSpec.describe Assignment, type: :model do
  let(:split) { FactoryBot.create :split }
  subject { FactoryBot.create :assignment, split: split }

  describe "variant" do
    it "validates presence of variant" do
      expect(subject).to validate_presence_of(:variant)
    end

    it "ensures validity of variant" do
      subject.variant = :not_really_a_variant
      expect(subject).not_to be_valid
      expect(subject.errors).to be_added(:variant, "must be specified in split's current variations")
    end
  end

  describe "split" do
    it "validates presence of split_id" do
      expect(subject).to validate_presence_of(:split).with_message(:required)
    end
  end

  describe "visitor" do
    it "validates presence of visitor_id" do
      expect(subject).to validate_presence_of(:visitor).with_message(:required)
    end
  end

  describe "mixpanel_result" do
    it "allows 'succcess'" do
      subject.mixpanel_result = "success"
      expect(subject).to be_valid
    end

    it "allows 'failure'" do
      subject.mixpanel_result = "failure"
      expect(subject).to be_valid
    end

    it "allows nil" do
      subject.mixpanel_result = nil
      expect(subject).to be_valid
    end

    it "allows empty string" do
      subject.mixpanel_result = ""
      expect(subject).to be_valid
    end

    it "normalizes" do
      expect(subject).to normalize_attribute(:mixpanel_result)
    end

    it "does not allow other values" do
      subject.mixpanel_result = "bogus"
      expect(subject).not_to be_valid
    end

    it "does not allow false" do
      subject.mixpanel_result = false
      expect(subject).not_to be_valid
    end

    it "does not allow 0" do
      subject.mixpanel_result = 0
      expect(subject).not_to be_valid
    end
  end

  describe ".to_hash" do
    it "is a hash of the split names to the variants" do
      split_1 = FactoryBot.create(:split, name: "split_1")
      split_2 = FactoryBot.create(:split, name: "split_2")
      FactoryBot.create(:assignment, split: split_1, variant: :hammer_time)
      FactoryBot.create(:assignment, split: split_2, variant: :touch_this)

      expect(described_class.to_hash).to eq(split_1: :hammer_time, split_2: :touch_this)
    end
  end

  describe ".unsynced_to_mixpanel" do
    it "returns assignments that were not a mixpanel success" do
      FactoryBot.create(:assignment, mixpanel_result: "success")
      mixpanel_failure = FactoryBot.create(:assignment, mixpanel_result: "failure")
      mixpanel_nil = FactoryBot.create(:assignment, mixpanel_result: nil)

      expect(described_class.unsynced_to_mixpanel.count).to eq 2
      expect(described_class.unsynced_to_mixpanel).to include(mixpanel_failure, mixpanel_nil)
    end
  end

  describe ".for_presentation" do
    let(:split) { FactoryBot.create(:split) }

    it "doesn't return assignments for finished splits" do
      finished_split = FactoryBot.create(:split, name: "finished_split", finished_at: Time.zone.now)
      FactoryBot.create(:assignment, split: finished_split)

      expect(described_class.for_presentation.map(&:split_name)).not_to include("finished_split")
    end

    it "doesn't return assignments for splits finished before built_at if provided" do
      finished_split = FactoryBot.create(:split, name: "finished_split", finished_at: Time.zone.now)
      FactoryBot.create(:assignment, split: finished_split)
      built_at = 5.minutes.from_now

      expect(described_class.for_presentation(built_at: built_at).map(&:split_name)).not_to include("finished_split")
    end

    it "returns assignments finished after built_at if provided" do
      finished_split = FactoryBot.create(:split, name: "finished_split", finished_at: Time.zone.now)
      FactoryBot.create(:assignment, split: finished_split)
      built_at = 5.minutes.ago

      expect(described_class.for_presentation(built_at: built_at).map(&:split_name)).to include("finished_split")
    end

    it "returns the split decision if newer than the assignment" do
      FactoryBot.create(:assignment, split: split, variant: :hammer_time)
      split.create_decision!(variant: :touch_this)

      expect(described_class.for_presentation.first.variant).to eq("touch_this")
    end

    it "returns the assignment if newer than the split decision" do
      split.create_decision!(variant: :touch_this)
      FactoryBot.create(:assignment, split: split, variant: :hammer_time)

      expect(described_class.for_presentation.first.variant).to eq("hammer_time")
    end
  end
end
