require 'rails_helper'

describe AppVersionBuildPath do
  it "is valid with valid args" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30Z"
      )
    ).to be_valid
  end

  it "is invalid with no app_name" do
    expect(
      described_class.new(
        app_name: "",
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30Z"
      )
    ).to have(1).error_on(:app_name)
  end

  it "is invalid with no version_number" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "",
        build_timestamp: "2019-04-16T14:35:30Z"
      )
    ).to have(1).error_on(:version_number)
  end

  it "is invalid with no build timestamp" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "1.0",
        build_timestamp: ""
      )
    ).to have(1).error_on(:build_timestamp)
  end

  it "is invalid with an illegal version number" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "01.0",
        build_timestamp: "2019-04-16T14:35:30Z"
      )
    ).to have(1).error_on(:version_number)
  end

  it "is invalid with a non-ISO date" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "1.0",
        build_timestamp: "2019-04-16 10:38:08 -0400"
      )
    ).to have(1).error_on(:build_timestamp)
  end

  it "is valid with an ISO date with millis" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30.123Z"
      )
    ).to be_valid
  end

  it "is invalid with an ISO date without seconds" do
    expect(
      described_class.new(
        app_name: "my_app",
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35Z"
      )
    ).to have(1).error_on(:build_timestamp)
  end

  describe "#app_build" do
    it "will not allow retrieval when invalid" do
      expect {
        described_class.new(
          app_name: "",
          version_number: "",
          build_timestamp: ""
        ).app_build
      }.to raise_error(/must be valid/)
    end

    it "is valid with a found app" do
      app = FactoryBot.create(:app, name: "my_app")

      app_build = described_class.new(
        app_name: "my_app",
        version_number: "1.0",
        build_timestamp: "2019-04-16T14:35:30Z"
      ).app_build

      expect(app_build.app_id).to eq(app.id)
      expect(app_build.version).to eq(AppVersion.new("1.0"))
      expect(app_build.built_at).to eq(Time.zone.parse("2019-04-16T14:35:30Z"))
    end

    it "will throw ActiveRecord::RecordNotFound when app can't be found by name" do
      expect {
        described_class.new(
          app_name: "my_app",
          version_number: "1.0",
          build_timestamp: "2019-04-16T14:35:30Z"
        ).app_build
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
