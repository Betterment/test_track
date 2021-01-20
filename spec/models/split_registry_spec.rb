require 'rails_helper'

RSpec.describe SplitRegistry do
  subject { described_class.new(as_of: Time.zone.now) }

  describe 'validations' do
    it "is valid with valid args" do
      expect(described_class.new(as_of: "2019-04-16T14:35:30Z")).to be_valid
    end

    it "is invalid with no timestamp" do
      expect(described_class.new(as_of: "")).to be_invalid
    end

    it "is invalid with a non-ISO date" do
      expect(described_class.new(as_of: "2019-04-16 10:38:08 -0400")).to be_invalid
    end

    it "is valid with an ISO date with millis" do
      expect(described_class.new(as_of: "2019-04-16T14:35:30.123Z")).to be_valid
    end

    it "is invalid with an ISO date without seconds" do
      expect(described_class.new(as_of: "2019-04-16T14:35Z")).to be_invalid
    end
  end

  describe "#splits" do
    it "doesn't cache the instance" do
      expect(subject.splits).to eq(subject.splits)
      expect(subject.splits).not_to eql(subject.splits)
    end

    it "returns active splits as of provided timestamp" do
      split = FactoryBot.create(:split)

      expect(subject.splits.all).to include(split)
    end

    it "doesn't return inactive splits as of given timestamp" do
      split = FactoryBot.create(:split, finished_at: 1.day.ago)

      expect(subject.splits.all).not_to include(split)
    end

    it "returns splits that were retired after the given timestamp" do
      split = FactoryBot.create(:split, finished_at: Time.zone.now)

      expect(described_class.new(as_of: 1.day.ago).splits.all).to include(split)
    end
  end

  describe '#experience_sampling_weight' do
    it "returns the default value as an integer" do
      expect(Rails.configuration.experience_sampling_weight).to eq(1)
    end
  end
end
