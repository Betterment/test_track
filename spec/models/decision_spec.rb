require 'rails_helper'

RSpec.describe Decision do
  let(:split_registry) { { off: 0, slow: 25, very_slow: 25, excruciatingly_slow: 50 }.stringify_keys }
  let(:split) { FactoryBot.create :split, name: "garbage_smasher_speed", registry: split_registry }
  let(:admin) { FactoryBot.create :admin }

  let(:off_assignments) { FactoryBot.create_list(:assignment, 1, split: split, variant: "off") }
  let(:on_assignments) do
    FactoryBot.create_list(:assignment, 1, split: split, variant: "slow")
      .concat(FactoryBot.create_list(:assignment, 1, split: split, variant: "very_slow"))
      .concat(FactoryBot.create_list(:assignment, 2, split: split, variant: "excruciatingly_slow"))
  end

  def assignments_of_split
    Assignment.where(split: split)
  end

  def build_decision_favoring(variant = "off")
    described_class.new(admin: admin, split: split, variant: variant)
  end

  context "variant already weighted 100%" do
    let(:split_registry) { { off: 100, slow: 0, very_slow: 0, excruciatingly_slow: 0 }.stringify_keys }

    it "re-assigns everyone even if registry is already weighted to variant" do
      expect(on_assignments.size).to eq 4

      decision = build_decision_favoring("off").tap(&:save!)

      expect(decision.count).to eq 4
      expect(assignments_of_split.where.not(variant: "off").count).to eq 0
      expect(assignments_of_split.where(variant: "off").count).to eq 4
    end
  end

  it "explodes if given a non-existant variant" do
    does_not_exist = "does_not_exist_variant"

    expect { build_decision_favoring(does_not_exist).save! }
      .to raise_error("Variant does_not_exist_variant is not a valid variant for split")

    expect(assignments_of_split.where(variant: does_not_exist).count).to eq 0
    expect(split.registry.keys).to match_array(split_registry.keys)
  end

  it "re-assigns visitors assigned to other variants to the off variant" do
    expect(off_assignments.size).to eq 1
    expect(on_assignments.size).to eq 4

    expect(assignments_of_split.where.not(variant: "off").count).to eq 4
    expect(assignments_of_split.where(variant: "off").count).to eq 1

    decision = build_decision_favoring("off").tap(&:save!)
    expect(decision.count).to eq 4

    expect(assignments_of_split.where.not(variant: "off").count).to eq 0
    expect(assignments_of_split.where(variant: "off").count).to eq 5
  end

  it "re-weights variant to 100%" do
    expect(split.registry["off"]).to eq 0

    build_decision_favoring("off").save!
    split.reload

    expect(split.registry["off"]).to eq 100
  end
end
