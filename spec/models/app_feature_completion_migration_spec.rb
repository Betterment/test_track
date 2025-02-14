require 'rails_helper'

RSpec.describe AppFeatureCompletionMigration do
  let(:app) { FactoryBot.create(:app) }
  let(:feature_gate) { FactoryBot.create(:feature_gate) }
  let(:experiment) { FactoryBot.create(:experiment) }

  it "creates AppFeatureCompletions" do
    subject = described_class.new(app:, feature_gate: feature_gate.name, version: "1.0")

    expect(subject.save).to be true

    expect(app.feature_completions.where(feature_gate:, version: "1.0")).to be_present
  end

  it "updates AppFeatureCompletions" do
    feature_completion = FactoryBot.create(:app_feature_completion, app:, feature_gate:, version: "0.9")
    subject = described_class.new(app:, feature_gate: feature_gate.name, version: "1.0")

    expect(subject.save).to be true

    feature_completion.reload
    expect(feature_completion.version).to eq(AppVersion.new("1.0"))
  end

  it "destroys AppFeatureCompletions" do
    FactoryBot.create(:app_feature_completion, app:, feature_gate:, version: "1.0")
    subject = described_class.new(app:, feature_gate: feature_gate.name, version: nil)

    expect(subject.save).to be true

    expect(app.feature_completions.where(feature_gate:, version: "1.0")).not_to be_present
  end

  it "destroys AppFeatureCompletions with empty-string version" do
    FactoryBot.create(:app_feature_completion, app:, feature_gate:, version: "1.0")
    subject = described_class.new(app:, feature_gate: feature_gate.name, version: "")

    expect(subject.save).to be true

    expect(app.feature_completions.where(feature_gate:, version: "1.0")).not_to be_present
  end

  it "is invalid when destroying for a nonexistant feature gate" do
    subject = described_class.new(app:, feature_gate: "nonexistent_enabled", version: nil)

    expect(subject).to have(1).error_on(:feature_gate)
    expect(subject).to have(0).errors_on(:version)
    expect(subject.save).to be false
  end

  it "is invalid with no feature gate" do
    subject = described_class.new(app:, feature_gate: "nonexistent_enabled", version: "1.0")

    expect(subject).to have(1).error_on(:feature_gate)
    expect(subject.save).to be false
  end

  it "is valid when destroying an unpersisted feature completion for idempotency" do
    subject = described_class.new(app:, feature_gate: feature_gate.name, version: nil)

    expect(subject.save).to be true

    expect(app.feature_completions.where(feature_gate:, version: "1.0")).not_to be_present
  end

  it "is invalid with an experiment" do
    subject = described_class.new(app:, feature_gate: experiment, version: "1.0")

    expect(subject).to have(1).error_on(:feature_gate)
    expect(subject.save).to be false
  end

  it "blows up with no app" do
    expect {
      described_class.new(app: nil, feature_gate: feature_gate.name, version: "1.0")
    }.to raise_error(/Must provide app/)
  end

  it "is invalid with an unparseable version" do
    subject = described_class.new(app:, feature_gate: feature_gate.name, version: "01.0")

    expect(subject).to have(1).error_on(:version)
    expect(subject.save).to be false
  end
end
