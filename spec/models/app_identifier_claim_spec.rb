require 'rails_helper'

RSpec.describe AppIdentifierClaim do
  let(:identifier_type) { FactoryBot.create(:identifier_type) }
  let(:visitor) { FactoryBot.create(:visitor) }
  let(:create_params) do
    {
      app_name: "my_app",
      version_number: "1.0",
      build_timestamp: "2019-04-16T14:35:30Z",
      identifier_type: identifier_type.name,
      visitor_id: visitor.id,
      value: "123"
    }
  end

  describe "#save" do
    context "validation" do
      it "is invalid if identifier_type is nil" do
        claim = described_class.new create_params.except(:identifier_type)
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:identifier_type, "can't be blank")
      end

      it "is invalid if visitor_id is nil" do
        claim = described_class.new create_params.except(:visitor_id)
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:visitor_id, "can't be blank")
      end

      it "is invalid if value is nil" do
        claim = described_class.new create_params.except(:value)
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:value, "can't be blank")
      end

      it "is invalid if identifier_type does not exist" do
        claim = described_class.new create_params.merge(identifier_type: "not_real_identifier_type")
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:identifier_type, "does not exist")
      end

      it "is invalid with no app_name" do
        claim = described_class.new create_params.merge(app_name: "")
        expect(claim).to have(1).error_on(:app_name)
      end

      it "is invalid with no version_number" do
        claim = described_class.new create_params.merge(version_number: "")
        expect(claim).to have(1).error_on(:version_number)
      end

      it "is invalid with no build timestamp" do
        claim = described_class.new create_params.merge(build_timestamp: "")
        expect(claim).to have(1).error_on(:build_timestamp)
      end
    end

    it "returns true when the IdentifierClaim saves successfully" do
      app_build = instance_double(App::Build)
      app_version_build_path = instance_double(AppVersionBuildPath, valid?: true, app_build:)
      allow(AppVersionBuildPath).to receive(:new).and_return app_version_build_path

      visitor = instance_double(Visitor)
      identifier = instance_double(Identifier, visitor:)
      identifier_claim = instance_double(IdentifierClaim, valid?: true, save!: true, identifier:)
      allow(IdentifierClaim).to receive(:new).and_return identifier_claim

      claim = described_class.new create_params

      expect(claim.save).to be(true)
    end
  end

  describe "#visitor" do
    it "returns nil before save" do
      claim = described_class.new create_params
      expect(claim.visitor).to be_nil
    end

    it "returns the identifier claim's identifier visitor after save" do
      app_build = instance_double(App::Build)
      app_version_build_path = instance_double(AppVersionBuildPath, valid?: true, app_build:)
      allow(AppVersionBuildPath).to receive(:new).and_return app_version_build_path

      visitor = instance_double(Visitor)
      identifier = instance_double(Identifier, visitor:)
      identifier_claim = instance_double(IdentifierClaim, valid?: true, save!: true, identifier:)
      allow(IdentifierClaim).to receive(:new).and_return identifier_claim

      claim = described_class.new create_params
      expect(claim.save).to be(true)

      expect(claim.visitor).to eq(visitor)
    end
  end

  describe "#app_build" do
    it "returns nil before save" do
      claim = described_class.new create_params
      expect(claim.app_build).to be_nil
    end

    it "returns the app version build path's app build after save" do
      app_build = instance_double(App::Build)
      app_version_build_path = instance_double(AppVersionBuildPath, valid?: true, app_build:)
      allow(AppVersionBuildPath).to receive(:new).and_return app_version_build_path

      visitor = instance_double(Visitor)
      identifier = instance_double(Identifier, visitor:)
      identifier_claim = instance_double(IdentifierClaim, valid?: true, save!: true, identifier:)
      allow(IdentifierClaim).to receive(:new).and_return identifier_claim

      claim = described_class.new create_params
      expect(claim.save).to be(true)

      expect(claim.app_build).to eq(app_build)
    end
  end
end
