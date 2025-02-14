require 'rails_helper'

RSpec.describe AppRemoteKillMigration do
  let(:app) { FactoryBot.create(:app) }
  let(:feature_gate) { FactoryBot.create(:feature_gate) }
  let(:experiment) { FactoryBot.create(:experiment) }

  it "creates AppRemoteKills" do
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "1.0",
      fixed_version: nil
    )

    expect(subject.save).to be true

    result = app.remote_kills.first
    expect(result.split).to eq(feature_gate)
    expect(result.reason).to eq("my_giant_bug_2019")
    expect(result.override_to).to eq("false")
    expect(result.first_bad_version).to eq(AppVersion.new("1.0"))
    expect(result.fixed_version).to be_nil
  end

  it "updates existing AppRemoteKills" do
    remote_kill = FactoryBot.create(
      :app_remote_kill,
      app:,
      split: feature_gate,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "0.9",
      fixed_version: nil
    )
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "0.9",
      fixed_version: "1.0"
    )

    expect(subject.save).to be true

    remote_kill.reload
    expect(remote_kill.fixed_version).to eq(AppVersion.new("1.0"))
  end

  it "destroys remote kills with null first_bad_version" do
    FactoryBot.create(
      :app_remote_kill,
      app:,
      split: feature_gate,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "0.9",
      fixed_version: nil
    )
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: nil,
      fixed_version: nil
    )

    expect(subject.save).to be true

    expect(app.remote_kills).to be_empty
  end

  it "destroys remote kills with empty string first_bad_version" do
    FactoryBot.create(
      :app_remote_kill,
      app:,
      split: feature_gate,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "0.9",
      fixed_version: nil
    )
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "",
      fixed_version: nil
    )

    expect(subject.save).to be true

    expect(app.remote_kills).to be_empty
  end

  it "nullifies fixed_version with an empty string for URLEncoded compatibility" do
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "0.9",
      fixed_version: ""
    )

    expect(subject.save).to be true

    result = app.remote_kills.first
    expect(result.fixed_version).to be_nil
  end

  it "is invalid with no split" do
    subject = described_class.new(
      app:,
      split: "nonexistant_split",
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: "0.9",
      fixed_version: ""
    )

    expect(subject).to have(1).error_on(:split)
    expect(subject.save).to be false
  end

  it "is invalid with no split on delete" do
    subject = described_class.new(
      app:,
      split: "nonexistant_split",
      reason: "my_giant_bug_2019",
      override_to: "false",
      first_bad_version: nil,
      fixed_version: nil
    )

    expect(subject).to have(1).error_on(:split)
    expect(subject.save).to be false
  end

  it "is invalid with no reason" do
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "",
      override_to: "false",
      first_bad_version: "1.0",
      fixed_version: nil
    )

    expect(subject).to have(1).error_on(:reason)
    expect(subject.save).to be false
  end

  it "is invalid with no reason on delete" do
    FactoryBot.create(:app_remote_kill, app:, split: feature_gate)
    subject = described_class.new(
      app:,
      split: feature_gate.name,
      reason: "",
      override_to: "false",
      first_bad_version: nil,
      fixed_version: nil
    )

    expect(subject).to have(1).error_on(:reason)
    expect(subject.save).to be false
    expect(app.remote_kills.count).to eq(1)
  end

  it "blows up with no app" do
    expect {
      described_class.new(
        app: nil,
        split: feature_gate.name,
        reason: "my_giant_bug_2019",
        override_to: "false",
        first_bad_version: "1.0",
        fixed_version: nil
      )
    }.to raise_error(/Must provide app/)
  end
end
