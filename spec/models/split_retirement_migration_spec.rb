require 'rails_helper'

RSpec.describe SplitRetirementMigration do
  it "retires a split" do
    split = FactoryBot.create(:split, name: "my_split", registry: { a: 100, b: 0 })

    expect(described_class.new(app: split.owner_app, split: "my_split", decision: "b").save).to be true

    split.reload
    expect(split.finished_at).to be_present
    expect(split.decided_at).to eq split.finished_at
    expect(split.registry).to eq("a" => 0, "b" => 100)
  end

  it "blows up with no app" do
    expect {
      described_class.new(app: nil, split: "my_split", decision: "b")
    }.to raise_error(/app/)
  end

  it "is invalid with a missing split" do
    app = FactoryBot.create(:app)
    subject = described_class.new(app: app, split: "my_split", decision: "b")
    expect(subject).to have(1).error_on(:split)
    expect(subject).to have(0).errors_on(:decision)
  end

  it "is invalid with a split from the wrong app" do
    FactoryBot.create(:split, name: "my_split", registry: { a: 100, b: 0 })
    other_app = FactoryBot.create(:app)

    subject = described_class.new(app: other_app, split: "my_split", decision: "b")
    expect(subject).to have(1).error_on(:split)
    expect(subject).to have(0).errors_on(:decision)
  end

  it "is invalid with a missing variant" do
    split = FactoryBot.create(:split, name: "my_split", registry: { a: 100, b: 0 })

    expect(described_class.new(app: split.owner_app, split: "my_split", decision: "nope")).to have(1).error_on(:decision)
  end
end
