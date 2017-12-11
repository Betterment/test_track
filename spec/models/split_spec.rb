require 'rails_helper'

RSpec.describe Split, type: :model do
  subject { FactoryBot.create(:split, registry: { treatment: 100 }) }

  it "validates presence of registry" do
    expect(subject).to validate_presence_of(:registry)
  end

  it "validates presence of name" do
    expect(subject).to validate_presence_of(:name)
  end

  it "validates uniqueness of name" do
    expect(subject).to validate_uniqueness_of(:name)
  end

  it "validates presence of owner_app" do
    expect(subject).to validate_presence_of(:owner_app).with_message(:required)
  end

  it "knows if symbol variant names are valid" do
    expect(subject).to have_variant(:treatment)
    expect(subject).not_to have_variant(:foo)
  end

  it "knows if string variant names are valid" do
    expect(subject).to have_variant('treatment')
    expect(subject).not_to have_variant('nope')
  end

  describe "#name" do
    it "rejects non-snake-case" do
      subject.name = 'fooBar'
      expect(subject).not_to be_valid
      expect(subject.errors[:name].first).to include("snake_case")
    end

    it "rejects new" do
      subject.name = 'my_new_foo'
      expect(subject).not_to be_valid
      expect(subject.errors[:name].first).to include("absolute time")
    end

    it "rejects ending in test" do
      subject.name = 'my_foo_test'
      expect(subject).not_to be_valid
      expect(subject.errors[:name].first).to include("redundant")
    end
  end

  describe "registry" do
    it 'succeeds when weight sum is equal to 100' do
      subject.registry = { off: 33, on: 34, maybe: 33 }
      expect(subject).to be_valid
    end

    it 'fails when weight sum is below 100' do
      subject.registry = { off: 0, on: 10 }
      expect(subject).not_to be_valid
      expect(subject.errors[:registry].first).to include("100%")
    end

    it 'fails when weight sum is above 100' do
      subject.registry = { off: 100, on: 10 }
      expect(subject).not_to be_valid
    end

    it 'fails when weight sum is nil' do
      subject.registry = { off: nil }
      expect(subject).not_to be_valid
    end

    it 'fails when weight sum is not numeric' do
      subject.registry = { off: "10%", on: "90%" }
      expect(subject).not_to be_valid
    end

    it "rejects non-snake-case variants" do
      subject.registry = { fooBar: 25, baz: 75 }
      expect(subject).not_to be_valid
      expect(subject.errors[:registry].first).to include("snake_case")
    end

    it "rejects non-integer weights" do
      subject.registry = { foo: 25.5, bar: 74.5 }
      expect(subject).not_to be_valid
      expect(subject.errors).to be_added :registry, "all weights must be integers"
    end

    it "succeeds when weights are numeric strings" do
      subject.registry = { foo: "25", bar: "75" }
      expect(subject).to be_valid
      expect(subject.registry).to eq "foo" => 25, "bar" => 75
    end
  end

  describe "#variants" do
    it "returns empty array when no variants exist" do
      expect(Split.new.variants).to eq []
    end

    it "returns variants" do
      expect(subject.variants).to eq ["treatment"]
    end
  end

  describe "#build_split_creation" do
    it "builds a split creation from the split" do
      subject.name = "my_split"
      split_creation = subject.build_split_creation
      expect(split_creation.weighting_registry).to eq("treatment" => 100)
      expect(split_creation.app).to eq subject.owner_app
      expect(split_creation.name).to eq "my_split"
    end

    it "allows params to be overridden" do
      subject.name = "my_split"
      split_creation = subject.build_split_creation(name: "a different name", weighting_registry: { foobar: 100 })
      expect(split_creation.weighting_registry).to eq("foobar" => 100)
      expect(split_creation.app).to eq subject.owner_app
      expect(split_creation.name).to eq "a different name"
    end
  end

  describe "#variant_weight" do
    it "returns the weight for the given variant" do
      expect(subject.variant_weight("treatment")).to eq 100
    end
  end

  describe "#assignment_count_for_variant" do
    it "returns count of given variant" do
      FactoryBot.create(:assignment, split: subject, variant: "treatment")

      expect(subject.assignment_count_for_variant("treatment")).to eq(1)
      expect(subject.assignment_count_for_variant("control")).to eq(0)
    end
  end

  describe "#build_decision" do
    it "builds a decision from the split" do
      subject.name = "my_split"
      decision = subject.build_decision
      expect(decision.send(:split)).to eq subject
    end
  end
end
