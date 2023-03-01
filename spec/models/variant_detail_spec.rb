require 'rails_helper'

RSpec.describe VariantDetail do
  let(:split) { FactoryBot.create(:split, name: "some_feature_enabled", registry: { true: 40, false: 60 }) }

  describe "#weight" do
    subject { described_class.new(split: split, variant: 'true') }

    it "is the weight of the given variant" do
      expect(subject.weight).to eq 40
    end
  end

  describe "#assignment_count" do
    let!(:true_assignment) { FactoryBot.create(:assignment, split: split, variant: "true") }
    let!(:false_assignment) { FactoryBot.create_pair(:assignment, split: split, variant: "false") }

    let(:true_presenter) { described_class.new(split: split, variant: 'true') }
    let(:false_presenter) { described_class.new(split: split, variant: 'false') }

    it "is the number of assignments of given variant" do
      expect(true_presenter.assignment_count).to eq 1
      expect(false_presenter.assignment_count).to eq 2
    end
  end

  describe "#retirable?" do
    subject { described_class.new(split: split, variant: 'true') }

    context 'with a 0% weight' do
      let(:split) { FactoryBot.create(:split, name: "some_feature_enabled", registry: { true: 0, false: 100 }) }

      context 'with no assignments' do
        it "is false" do
          expect(subject).not_to be_retirable
        end
      end

      context 'with some assignments' do
        let!(:assignment) { FactoryBot.create(:assignment, split: split, variant: "true") }

        it "is true" do
          expect(subject).to be_retirable
        end
      end
    end

    context 'with a non0% weight' do
      let(:split) { FactoryBot.create(:split, name: "some_feature_enabled", registry: { true: 1, false: 99 }) }

      context 'with no assignments' do
        it "is false" do
          expect(subject).not_to be_retirable
        end
      end

      context 'with some assignments' do
        let!(:assignment) { FactoryBot.create(:assignment, split: split, variant: "true") }

        it "is false for a non 0% weight that has assignments" do
          expect(subject).not_to be_retirable
        end
      end
    end
  end

  describe '#valid?' do
    context 'with a variant that exists' do
      subject { FactoryBot.build(:variant_detail, split: split, variant: 'true') }

      it 'returns true' do
        expect(subject.valid?).to be true
      end
    end

    context 'with a variant that does not exist' do
      subject { FactoryBot.build(:variant_detail, split: split, variant: 'duck') }

      it 'returns false' do
        expect(subject.valid?).to be false
        expect(subject.errors[:base]).to include 'Variant does not exist: duck'
      end
    end
  end
end
