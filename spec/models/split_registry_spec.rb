require 'rails_helper'

RSpec.describe SplitRegistry do
  subject { SplitRegistry.instance }

  describe "#splits" do
    it "doesn't cache the instance" do
      expect(subject.splits).to eq(subject.splits)
      expect(subject.splits).not_to eql(subject.splits)
    end

    it "returns active splits" do
      split = FactoryBot.create(:split)

      expect(subject.splits.all).to include(split)
    end

    it "doesn't return inactive splits" do
      split = FactoryBot.create(:split, finished_at: Time.zone.now)

      expect(subject.splits.all).not_to include(split)
    end
  end

  describe "#experience_sampling_weight" do
    context "bypassing singleton memoization" do
      subject { SplitRegistry.send(:new) }

      it "memoizes the env var fetch" do
        allow(ENV).to receive(:fetch).and_call_original

        subject.experience_sampling_weight
        subject.experience_sampling_weight

        expect(ENV).to have_received(:fetch).with('EXPERIENCE_SAMPLING_WEIGHT', any_args).exactly(:once)
      end

      it "returns 1 with no env var" do
        with_env EXPERIENCE_SAMPLING_WEIGHT: nil do
          expect(subject.experience_sampling_weight).to eq 1
        end
      end

      it "returns an positive value specified" do
        with_env EXPERIENCE_SAMPLING_WEIGHT: '10' do
          expect(subject.experience_sampling_weight).to eq 10
        end
      end

      it "returns zero when specified" do
        with_env EXPERIENCE_SAMPLING_WEIGHT: '0' do
          expect(subject.experience_sampling_weight).to eq 0
        end
      end

      it "blows up on negative" do
        with_env EXPERIENCE_SAMPLING_WEIGHT: '-1' do
          expect { subject.experience_sampling_weight }.to raise_error(/greater than or equal/)
        end
      end
    end
  end
end
