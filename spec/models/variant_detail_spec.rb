require 'rails_helper'

RSpec.describe VariantDetail do
  let(:split) { FactoryGirl.create(:split, name: 'split_enabled', registry: { true: 50, false: 50 }) }

  describe '#valid?' do
    context 'with a variant that exists' do
      subject { FactoryGirl.build(:variant_detail, split: split, variant: 'true') }

      it 'returns true' do
        expect(subject.valid?).to eq true
      end
    end

    context 'with a variant that does not exist' do
      subject { FactoryGirl.build(:variant_detail, split: split, variant: 'duck') }

      it 'returns false' do
        expect(subject.valid?).to eq false
        expect(subject.errors[:base]).to include 'Variant does not exist: duck'
      end
    end
  end
end
