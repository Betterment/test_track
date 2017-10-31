require 'rails_helper'

RSpec.describe Visitor, type: :model do
  subject { FactoryBot.create(:visitor) }

  let(:banana_split) { FactoryBot.create(:split, name: :banana, registry: { green: 50, squishy: 50 }) }
  let(:torque_split) { FactoryBot.create(:split, name: :torque, registry: { front: 40, rear: 60 }) }

  describe "#assignment_registry" do
    it "is a hash representation of the assignments" do
      FactoryBot.create(:assignment, visitor: subject, split: banana_split, variant: 'green')
      FactoryBot.create(:assignment, visitor: subject, split: torque_split, variant: 'front')
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
