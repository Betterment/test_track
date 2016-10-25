require 'rails_helper'

RSpec.describe VariantRetirement do
  let(:admin) { FactoryGirl.create :admin }
  let(:split) { FactoryGirl.create :split, name: "color", registry: { red: 50, blue: 0, yellow: 50 } }

  let(:params) do
    {
      retiring_variant: "blue",
      split_id: split.id,
      admin: admin
    }
  end

  subject { described_class.new(params) }

  describe "#save!" do
    before do
      allow(SecureRandom).to receive(:random_number).and_return(25, 75, 25, 75)
      FactoryGirl.create(:assignment, split: split, variant: :red)
      FactoryGirl.create(:assignment, split: split, variant: :yellow)
    end

    context "assignments exist to be retired" do
      before do
        FactoryGirl.create_list(:assignment, 4, split: split, variant: :blue)
      end

      it "creates one bulk assignment per active variant" do
        expect { subject.save! }
          .to change { BulkAssignment.count }.by(2)

        red_bulk_assignment = BulkAssignment.find_by!(split: split, variant: :red)
        yellow_bulk_assignment = BulkAssignment.find_by!(split: split, variant: :yellow)

        expect(red_bulk_assignment.reason).to eq "Retiring blue"
        expect(yellow_bulk_assignment.reason).to eq "Retiring blue"
      end

      it "creates previous assignments for the retiring assignments" do
        expect { subject.save! }
          .to change { PreviousAssignment.count }.by(4)

        PreviousAssignment.all.each do |previous_assignment|
          expect(previous_assignment.variant).to eq "blue"
        end
      end

      it "distributes the retiring assignments according to the active variant's weights" do
        subject.save!

        expect(Assignment.where(split: split, variant: :red).count).to eq 3
        expect(Assignment.where(split: split, variant: :yellow).count).to eq 3
        expect(Assignment.where(split: split, variant: :blue).count).to eq 0
      end

      it "does not create bulk assignments for active variants that receive no new assignments" do
        allow(SecureRandom).to receive(:random_number).and_return(25) # put everyone in red variant

        expect { subject.save! }
          .to change { BulkAssignment.count }.by(1)
          .and change { PreviousAssignment.count }.by(4)
      end
    end

    context "no assignments exist to be retired" do
      it "no-ops" do
        expect { subject.save! }
          .to change { BulkAssignment.count }.by(0)
          .and change { PreviousAssignment.count }.by(0)
      end
    end
  end
end
