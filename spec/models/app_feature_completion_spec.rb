require 'rails_helper'

RSpec.describe AppFeatureCompletion do
  describe ".satisfied_by" do
    let(:app) { FactoryBot.create(:app) }
    let(:app_build) { app.define_build(built_at: Time.zone.now, version: "1.0") }
    let(:different_app) { FactoryBot.create(:app) }

    it "returns a record for an app_build with the same app_id and version" do
      fc = FactoryBot.create(:app_feature_completion, app:, version: "1.0")

      expect(described_class.satisfied_by(app_build)).to include(fc)
    end

    it "returns a record for an app_build with a greater version" do
      fc = FactoryBot.create(:app_feature_completion, app:, version: "0.9")

      expect(described_class.satisfied_by(app_build)).to include(fc)
    end

    it "doesn't return a record for an app_build with a lower version" do
      fc = FactoryBot.create(:app_feature_completion, app:, version: "1.1")

      expect(described_class.satisfied_by(app_build)).not_to include(fc)
    end

    it "doesn't return a record for an app build for a different app" do
      fc = FactoryBot.create(:app_feature_completion, app: different_app, version: "1.0")

      expect(described_class.satisfied_by(app_build)).not_to include(fc)
    end
  end
end
