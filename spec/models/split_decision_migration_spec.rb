require 'rails_helper'

RSpec.describe SplitDecisionMigration do
  it "retires a split" do
    split = FactoryBot.create(:split, name: "my_split", registry: { a: 100, b: 0 }, finished_at: Time.zone.now)

    expect(described_class.new(app: split.owner_app, split: "my_split", variant: "b").save).to eq true

    split.reload
    expect(split.finished_at).to be_nil
    expect(split.decided_at).to be_present
    expect(split.registry).to eq("a" => 0, "b" => 100)
  end

  it "blows up with no app" do
    expect {
      described_class.new(app: nil, split: "my_split", variant: "b")
    }.to raise_error(/app/)
  end

  it "is invalid with a missing split" do
    app = FactoryBot.create(:app)
    subject = described_class.new(app: app, split: "my_split", variant: "b")
    expect(subject).to have(1).error_on(:split)
    expect(subject).to have(0).errors_on(:variant)
  end

  it "is invalid with a split from the wrong app" do
    FactoryBot.create(:split, name: "my_split", registry: { a: 100, b: 0 })
    other_app = FactoryBot.create(:app)

    subject = described_class.new(app: other_app, split: "my_split", variant: "b")
    expect(subject).to have(1).error_on(:split)
    expect(subject).to have(0).errors_on(:variant)
  end

  it "is invalid with a missing variant" do
    split = FactoryBot.create(:split, name: "my_split", registry: { a: 100, b: 0 })

    expect(described_class.new(app: split.owner_app, split: "my_split", variant: "nope")).to have(1).error_on(:variant)
  end
end
