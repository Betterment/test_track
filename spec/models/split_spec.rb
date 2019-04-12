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

    it "fails if decided with no winning variant" do
      subject.registry = { foo: "25", bar: "75" }
      subject.decided_at = Time.zone.now
      expect(subject).not_to be_valid
      expect(subject.errors).to be_added :registry, "must have a winning variant if decided"
    end

    it "succeeds if decided with a winning variant" do
      subject.registry = { foo: "0", bar: "100" }
      subject.decided_at = Time.zone.now
      expect(subject).to be_valid
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

  describe "#build_config" do
    it "builds a split config from the split" do
      subject.name = "my_split"
      config = subject.build_config
      expect(config.weighting_registry).to eq("treatment" => 100)
      expect(config.app).to eq subject.owner_app
      expect(config.name).to eq "my_split"
    end

    it "allows weighting registry to be overridden" do
      config = subject.build_config(weighting_registry: { foobar: 100 })
      expect(config.weighting_registry).to eq("foobar" => 100)
    end

    it "doesn't allow split name to be overridden" do
      subject.name = "my_split"
      config = subject.build_config(name: "a different name")
      expect(config.name).to eq "my_split"
    end

    it "doesn't allow app to be overridden" do
      subject.name = "my_split"
      config = subject.build_config(app: FactoryBot.build_stubbed(:app))
      expect(config.app).to eq subject.owner_app
    end
  end

  describe "#reconfigure!" do
    it "reflects changes in the instance" do
      subject.reconfigure!(weighting_registry: { baz: 100 })

      expect(subject.registry).to eq("treatment" => 0, "baz" => 100)
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

  describe ".active" do
    it "returns unfinished splits without arguments" do
      split = FactoryBot.create(:split)

      expect(described_class.active).to include(split)
    end

    it "returns unfinished splits with as_of: provided" do
      split = FactoryBot.create(:split)

      expect(described_class.active(as_of: Time.zone.now)).to include(split)
    end

    it "returns splits finished after as_of:" do
      split = FactoryBot.create(:split, finished_at: Time.zone.now)

      expect(described_class.active(as_of: 1.minute.ago)).to include(split)
    end

    it "doesn't return splits finished simultaneously with as_of:" do
      t = Time.zone.now
      split = FactoryBot.create(:split, finished_at: t)

      expect(described_class.active(as_of: t)).not_to include(split)
    end

    it "doesn't return splits finished before as_of:" do
      split = FactoryBot.create(:split, finished_at: 1.day.ago)

      expect(described_class.active(as_of: Time.zone.now)).not_to include(split)
    end
  end

  describe ".with_feature_incomplete_knockouts_for" do
    let(:app) { FactoryBot.create(:app) }
    let(:app_build) { app.define_build(built_at: Time.zone.now, version: "1.0") }

    it "respects existing selects" do
      split = FactoryBot.create(:split, feature_gate: false)

      result = Split.select(:name).with_feature_incomplete_knockouts_for(app_build).find(split.id)

      expect(result).not_to be_feature_incomplete
      expect(result).to respond_to(:name)
      expect(result).not_to respond_to(:finished_at)
    end

    it "isn't feature_incomplete for non-feature gates" do
      split = FactoryBot.create(:split, feature_gate: false)
      expect(Split.with_feature_incomplete_knockouts_for(app_build).find(split.id)).not_to be_feature_incomplete
    end

    it "returns readonly records" do
      split = FactoryBot.create(:split, feature_gate: false)
      expect(Split.with_feature_incomplete_knockouts_for(app_build).find(split.id)).to be_readonly
    end

    it "isn't feature_incomplete for feature gates with a feature completion" do
      split = FactoryBot.create(:split, feature_gate: true)
      FactoryBot.create(:app_feature_completion, app: app, version: "1.0", split: split)
      expect(Split.with_feature_incomplete_knockouts_for(app_build).find(split.id)).not_to be_feature_incomplete
    end

    it "is feature_incomplete for feature gates with no feature completion" do
      split = FactoryBot.create(:split, feature_gate: true)
      expect(Split.with_feature_incomplete_knockouts_for(app_build).find(split.id)).to be_feature_incomplete
    end

    it "is backed by AppFeatureCompletion.satisfied_by" do
      allow(AppFeatureCompletion).to receive(:satisfied_by).and_call_original

      Split.with_feature_incomplete_knockouts_for(app_build)

      expect(AppFeatureCompletion).to have_received(:satisfied_by).with(app_build)
    end
  end

  describe ".arel_excluding_incomplete_features_for" do
    let(:app) { FactoryBot.create(:app) }
    let(:app_build) { app.define_build(built_at: Time.zone.now, version: "1.0") }

    it "includes non-feature gates" do
      split = FactoryBot.create(:split, feature_gate: false)
      expect(Split.where(Split.arel_excluding_incomplete_features_for(app_build))).to include(split)
    end

    it "includes feature gates with a feature completion" do
      split = FactoryBot.create(:split, feature_gate: true)
      FactoryBot.create(:app_feature_completion, app: app, version: "1.0", split: split)
      expect(Split.where(Split.arel_excluding_incomplete_features_for(app_build))).to include(split)
    end

    it "doesn't include feature gates with no feature completion" do
      split = FactoryBot.create(:split, feature_gate: true)
      expect(Split.where(Split.arel_excluding_incomplete_features_for(app_build))).not_to include(split)
    end

    it "is backed by AppFeatureCompletion.satisfied_by" do
      allow(AppFeatureCompletion).to receive(:satisfied_by).and_call_original

      Split.where(Split.arel_excluding_incomplete_features_for(app_build))

      expect(AppFeatureCompletion).to have_received(:satisfied_by).with(app_build)
    end
  end

  describe ".with_remote_kill_knockouts_for" do
    let(:app) { FactoryBot.create(:app) }
    let(:app_build) { app.define_build(built_at: Time.zone.now, version: "1.0") }

    it "respects existing selects" do
      split = FactoryBot.create(:split)

      result = Split.select(:name).with_remote_kill_knockouts_for(app_build).find(split.id)

      expect(result.remote_kill_override_to).to be_nil
      expect(result).to respond_to(:name)
      expect(result).not_to respond_to(:finished_at)
    end

    it "has a nil override without a remote kill" do
      split = FactoryBot.create(:split)

      expect(Split.with_remote_kill_knockouts_for(app_build).find(split.id).remote_kill_override_to).to eq(nil)
    end

    it "returns readonly records" do
      split = FactoryBot.create(:split)

      expect(Split.with_remote_kill_knockouts_for(app_build).find(split.id)).to be_readonly
    end

    it "has a nil override for a remote kill that doesn't overlap" do
      split = FactoryBot.create(:split)
      FactoryBot.create(:app_remote_kill, app: app, split: split, first_bad_version: "1.1", fixed_version: "1.2", override_to: :touch_this)

      expect(Split.with_remote_kill_knockouts_for(app_build).find(split.id).remote_kill_override_to).to eq(nil)
    end

    it "has an override for a remote kill that overlaps" do
      split = FactoryBot.create(:split)
      FactoryBot.create(:app_remote_kill, app: app, split: split, first_bad_version: "0.9", fixed_version: "1.1", override_to: :touch_this)
      expect(Split.with_remote_kill_knockouts_for(app_build).find(split.id).remote_kill_override_to).to eq("touch_this")
    end

    it "is backed by AppRemoteKill.affecting" do
      allow(AppRemoteKill).to receive(:affecting).and_call_original

      Split.with_remote_kill_knockouts_for(app_build)

      expect(AppRemoteKill).to have_received(:affecting).with(app_build)
    end
  end

  describe ".arel_excluding_remote_kills_for" do
    let(:app) { FactoryBot.create(:app) }
    let(:app_build) { app.define_build(built_at: Time.zone.now, version: "1.0") }

    it "includes a split with no remote kill" do
      split = FactoryBot.create(:split)
      expect(Split.where(Split.arel_excluding_remote_kills_for(app_build))).to include(split)
    end

    it "includes a split when there's a remote kill for another split" do
      split = FactoryBot.create(:split)
      other_split = FactoryBot.create(:split)
      FactoryBot.create(:app_remote_kill, split: other_split, app: app, first_bad_version: "0.8", fixed_version: "2.0")

      expect(Split.where(Split.arel_excluding_remote_kills_for(app_build))).to include(split)
    end

    it "includes a split with a remote kill not conflicting with version" do
      split = FactoryBot.create(:split)
      FactoryBot.create(:app_remote_kill, split: split, app: app, first_bad_version: "2.0", fixed_version: "2.1")

      expect(Split.where(Split.arel_excluding_remote_kills_for(app_build))).to include(split)
    end

    it "doesn't include a split with a remote kill spanning version" do
      split = FactoryBot.create(:split)
      FactoryBot.create(:app_remote_kill, split: split, app: app, first_bad_version: "0.8", fixed_version: "2.0")

      expect(Split.where(Split.arel_excluding_remote_kills_for(app_build))).not_to include(split)
    end

    it "is backed by AppRemoteKill.affecting with default override args" do
      allow(AppRemoteKill).to receive(:affecting).and_call_original

      Split.arel_excluding_remote_kills_for(app_build)

      expect(AppRemoteKill).to have_received(:affecting).with(app_build, override: false, overridden_at: nil)
    end

    it "is backed by AppRemoteKill.affecting with explicit override args" do
      allow(AppRemoteKill).to receive(:affecting).and_call_original
      t = Time.zone.now

      Split.arel_excluding_remote_kills_for(app_build, override: true, overridden_at: t)

      expect(AppRemoteKill).to have_received(:affecting).with(app_build, override: true, overridden_at: t)
    end
  end

  describe "#registry" do
    context "with a feature gate" do
      subject { FactoryBot.create(:split, registry: { true: 50, false: 50 }, feature_gate: true) }

      it "returns the column value if it doesn't respond to feature_incomplete?" do
        expect(subject).not_to respond_to(:feature_incomplete?)
        expect(subject.registry).to eq("true" => 50, "false" => 50)
      end

      it "overrides to 100% false if feature-incomplete" do
        fc = FactoryBot.create(:app_feature_completion, version: "1.1", split: subject)
        app_build = fc.app.define_build(built_at: Time.zone.now, version: "1.0")

        subject_with_knockouts = Split.for_app_build(app_build).find(subject.id)
        expect(subject_with_knockouts).to be_feature_incomplete
        expect(subject_with_knockouts.registry).to eq("true" => 0, "false" => 100)
      end

      it "returns the column value if it isn't feature-incomplete" do
        fc = FactoryBot.create(:app_feature_completion, version: "1.1", split: subject)
        app_build = fc.app.define_build(built_at: Time.zone.now, version: "1.1")

        subject_with_knockouts = Split.for_app_build(app_build).find(subject.id)

        expect(subject_with_knockouts).not_to be_feature_incomplete
        expect(subject_with_knockouts.registry).to eq("true" => 50, "false" => 50)
      end

      it "prefers a remote kill over a feature incompletion if both are present" do
        rk = FactoryBot.create(:app_remote_kill, split: subject, first_bad_version: "0.9", fixed_version: nil, override_to: "true")
        fc = FactoryBot.create(:app_feature_completion, split: subject, app: rk.app, version: "1.1")
        app_build = fc.app.define_build(built_at: Time.zone.now, version: "1.0")

        subject_with_knockouts = Split.for_app_build(app_build).find(subject.id)
        expect(subject_with_knockouts).to be_feature_incomplete
        expect(subject_with_knockouts.registry).to eq("true" => 100, "false" => 0)
      end

      context "missing a false variant (gasp!)" do
        subject { FactoryBot.create(:split, registry: { true: 50, not_false: 50 }, feature_gate: true) }

        it "returns the column value and logs an error if feature-incomplete" do
          fc = FactoryBot.create(:app_feature_completion, version: "1.1", split: subject)
          app_build = fc.app.define_build(built_at: Time.zone.now, version: "1.0")

          subject_with_knockouts = Split.with_feature_incomplete_knockouts_for(app_build).find(subject.id)
          allow(subject_with_knockouts.logger).to receive(:error).and_call_original

          expect(subject_with_knockouts).to be_feature_incomplete
          expect(subject_with_knockouts.registry).to eq("true" => 50, "not_false" => 50)
          expect(subject_with_knockouts.logger).to have_received(:error).with(/variant "false" not found/)
        end
      end
    end

    context "with a non-feature-gate" do
      subject { FactoryBot.create(:split, registry: { hammer_time: 50, touch_this: 50 }) }

      it "returns the column value if it doesn't respond to remote_kill_override_to" do
        expect(subject).not_to respond_to(:remote_kill_override_to)
        expect(subject.registry).to eq("hammer_time" => 50, "touch_this" => 50)
      end

      it "overrides to 100% remote_kill_override_to if remote killed" do
        fc = FactoryBot.create(:app_remote_kill, split: subject, first_bad_version: "0.9", fixed_version: "1.1")
        app_build = fc.app.define_build(built_at: Time.zone.now, version: "1.0")

        subject_with_knockouts = Split.for_app_build(app_build).find(subject.id)
        expect(subject_with_knockouts.remote_kill_override_to).to eq "touch_this"
        expect(subject_with_knockouts.registry).to eq("hammer_time" => 0, "touch_this" => 100)
      end

      it "returns the column value if not remote killed" do
        fc = FactoryBot.create(:app_remote_kill, split: subject, first_bad_version: "1.1", fixed_version: "1.2")
        app_build = fc.app.define_build(built_at: Time.zone.now, version: "1.0")

        subject_with_knockouts = Split.for_app_build(app_build).find(subject.id)
        expect(subject_with_knockouts.remote_kill_override_to).to eq nil
        expect(subject_with_knockouts.registry).to eq("hammer_time" => 50, "touch_this" => 50)
      end
    end
  end

  describe ".for_presentation" do
    it "calls active with no args if no app_build is provided" do
      allow(Split).to receive(:for_app_build).and_call_original
      allow(Split).to receive(:active).and_call_original

      expect(Split.for_presentation).to be_a(ActiveRecord::Relation)

      expect(Split).to have_received(:active).with(no_args)
      expect(Split).not_to have_received(:for_app_build)
    end

    it "calls for_app_build if app_build is provided" do
      allow(Split).to receive(:for_app_build).and_call_original
      app_build = FactoryBot.build_stubbed(:app).define_build(built_at: Time.zone.now, version: "1.0")

      expect(Split.for_presentation(app_build: app_build)).to be_a(ActiveRecord::Relation)

      expect(Split).to have_received(:for_app_build).with(app_build)
    end
  end

  describe ".for_app_build" do
    it "it calls active with built_at" do
      allow(Split).to receive(:active).and_call_original
      t = Time.zone.now
      app_build = FactoryBot.build_stubbed(:app).define_build(built_at: t, version: "1.0")

      expect(Split.for_app_build(app_build)).to be_a(ActiveRecord::Relation)

      expect(Split).to have_received(:active).with(as_of: t)
    end

    it "calls with_feature_incomplete_knockouts_for with app_build" do
      allow(Split).to receive(:with_feature_incomplete_knockouts_for).and_call_original
      app_build = FactoryBot.build_stubbed(:app).define_build(built_at: Time.zone.now, version: "1.0")

      expect(Split.for_app_build(app_build)).to be_a(ActiveRecord::Relation)

      expect(Split).to have_received(:with_feature_incomplete_knockouts_for).with(app_build)
    end

    it "calls with_remote_kill_knockouts_for with app_build and default override args" do
      allow(Split).to receive(:with_remote_kill_knockouts_for).and_call_original
      app_build = FactoryBot.build_stubbed(:app).define_build(built_at: Time.zone.now, version: "1.0")

      expect(Split.for_app_build(app_build)).to be_a(ActiveRecord::Relation)

      expect(Split).to have_received(:with_remote_kill_knockouts_for).with(app_build)
    end
  end
end
