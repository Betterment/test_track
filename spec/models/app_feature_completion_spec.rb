require 'rails_helper'

RSpec.describe AppFeatureCompletion do
  describe ".satisfied_by" do
    let(:split) { FactoryBot.create(:split) }
    let(:app) { FactoryBot.create(:app) }
    let(:app_build) { app.define_build(built_at: Time.zone.now, version: "1.0") }
    let(:different_app) { FactoryBot.create(:app) }

    it "blows up if you don't BYO splits table" do
      FactoryBot.create(:app_feature_completion, app: app, split: split, version: "1.0")

      expect { described_class.satisfied_by(app_build).to_a }.to raise_error(/missing FROM-clause entry for table "splits"/)
    end

    it "returns a record for an app_build with the same app_id and version" do
      fc = FactoryBot.create(:app_feature_completion, app: app, split: split, version: "1.0")

      expect(described_class.joins(:split).satisfied_by(app_build)).to include(fc)
    end

    it "returns a record for an app_build with a greater version" do
      fc = FactoryBot.create(:app_feature_completion, app: app, split: split, version: "0.9")

      expect(described_class.joins(:split).satisfied_by(app_build)).to include(fc)
    end

    it "doesn't return a record for an app_build with a lower version" do
      fc = FactoryBot.create(:app_feature_completion, app: app, split: split, version: "1.1")

      expect(described_class.joins(:split).satisfied_by(app_build)).not_to include(fc)
    end

    it "doesn't return a record for an app build for a different app" do
      fc = FactoryBot.create(:app_feature_completion, app: different_app, split: split, version: "1.0")

      expect(described_class.joins(:split).satisfied_by(app_build)).not_to include(fc)
    end
  end
end
