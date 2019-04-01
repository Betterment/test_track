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

    context "with app_build provided" do
      let(:feature_gate) { FactoryBot.create(:split, name: "bla_enabled") }
      let(:random_split) { FactoryBot.create(:split, name: "random") }
      let(:app) { FactoryBot.create(:app) }
      let(:new_app_build) { app.define_build(version: "5.0.1", built_at: Time.zone.now) }

      it "doesn't return assignments for splits finished before built_at" do
        finished_split = FactoryBot.create(:split, name: "finished_split", finished_at: Time.zone.now)
        FactoryBot.create(:assignment, split: finished_split)
        app_build = FactoryBot.build_stubbed(:app).define_build(built_at: 5.minutes.from_now, version: "1.0")

        expect(described_class.for_presentation(app_build: app_build).map(&:split_name)).not_to include("finished_split")
      end

      it "returns assignments for splits finished after built_at" do
        finished_split = FactoryBot.create(:split, name: "finished_split", finished_at: Time.zone.now)
        FactoryBot.create(:assignment, split: finished_split)
        app_build = FactoryBot.build_stubbed(:app).define_build(built_at: 5.minutes.ago, version: "1.0")

        expect(described_class.for_presentation(app_build: app_build).map(&:split_name)).to include("finished_split")
      end

      it "doesn't return assignments for feature gates that have no feature_completion" do
        FactoryBot.create(:assignment, split: feature_gate)

        expect(described_class.for_presentation(app_build: new_app_build)).to be_empty
      end

      it "doesn't return assignments for feature gates that have a feature_completion with a greater version" do
        FactoryBot.create(:assignment, split: feature_gate)
        FeatureCompletion.create!(app: app, split: feature_gate, version: "5.0.2")

        expect(described_class.for_presentation(app_build: new_app_build)).to be_empty
      end

      it "returns assignments for feature gates that have a feature_completion with the same version" do
        FeatureCompletion.create!(app: app, split: feature_gate, version: "5.0.1")
        FactoryBot.create(:assignment, split: feature_gate)

        expect(described_class.for_presentation(app_build: new_app_build)).to be_present
      end

      it "returns assignments for unsuffixed splits that have no feature_completion" do
        FactoryBot.create(:assignment, split: random_split)

        expect(described_class.for_presentation(app_build: new_app_build)).to be_present
      end
    end

    it "returns nothing if the decision is newer than the assignment" do
      FactoryBot.create(:assignment, split: split, variant: :hammer_time)
      split.create_decision!(variant: :touch_this)

      expect(described_class.for_presentation).to be_empty
    end

    it "returns the assignment if newer than the split decision" do
      split.create_decision!(variant: :touch_this)
      FactoryBot.create(:assignment, split: split, variant: :hammer_time)

      expect(described_class.for_presentation.first.variant).to eq("hammer_time")
    end
  end
end
