require 'rails_helper'

RSpec.describe VariantDetail do
  describe "#weight" do
    it "is the weight of the given variant" do
      split = FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 40, false: 60 })
      expect(described_class.new(split, "true").weight).to eq 40
    end
  end

  describe "#assignment_count" do
    it "is the number of assignments of given variant" do
      split = FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 40, false: 60 })
      FactoryGirl.create(:assignment, split: split, variant: "true")
      FactoryGirl.create_pair(:assignment, split: split, variant: "false")

      expect(described_class.new(split, "true").assignment_count).to eq 1
      expect(described_class.new(split, "false").assignment_count).to eq 2
    end
  end

  describe "#retirable?" do
    it "is false for a 0% weight that has no assignments" do
      split = FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 0, false: 100 })

      expect(described_class.new(split, "true")).not_to be_retirable
    end

    it "is true for a 0% weight that has assignments" do
      split = FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 0, false: 100 })
      FactoryGirl.create(:assignment, split: split, variant: "true")

      expect(described_class.new(split, "true")).to be_retirable
    end

    it "is false for a non 0% weight with no assignments" do
      split = FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 1, false: 99 })

      expect(described_class.new(split, "true")).not_to be_retirable
    end

    it "is false for a non 0% weight that has assignments" do
      split = FactoryGirl.create(:split, name: "some_feature_enabled", registry: { true: 1, false: 99 })
      FactoryGirl.create(:assignment, split: split, variant: "true")

      expect(described_class.new(split, "true")).not_to be_retirable
    end
  end
end
