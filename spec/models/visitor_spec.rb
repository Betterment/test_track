require 'rails_helper'

RSpec.describe Visitor, type: :model do
  subject { FactoryGirl.create(:visitor) }

  let(:banana_split) { FactoryGirl.create(:split, name: :banana, registry: { green: 50, squishy: 50 }) }
  let(:torque_split) { FactoryGirl.create(:split, name: :torque, registry: { front: 40, rear: 60 }) }

  describe "#assignment_registry" do
    it "is a hash representation of the assignments" do
      FactoryGirl.create(:assignment, visitor: subject, split: banana_split, variant: 'green')
      FactoryGirl.create(:assignment, visitor: subject, split: torque_split, variant: 'front')
      expect(subject.assignment_registry).to eq(banana: :green, torque: :front)
    end
  end

  it "has many unsynced assignments" do
    expect(subject).to have_many(:unsynced_assignments)
  end

  it "has many unsynced assignments" do
    expect(subject).to have_many(:unsynced_splits)
  end
end
