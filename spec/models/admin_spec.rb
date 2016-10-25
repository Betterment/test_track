require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe ".from_saml" do
    let(:info) { { email: "herman@example.com", name: "Herman Miller" } }
    let(:auth) { OmniAuth::AuthHash.new(uid: "herman@example.com", info: info) }

    it "creates a user if one does not exist" do
      expect do
        admin = Admin.from_saml(auth)
        expect(admin.full_name).to eq "Herman Miller"
        expect(admin.email).to eq "herman@example.com"
        expect(admin.provider).to eq "SAML"
      end.to change { Admin.count }.by(1)
    end

    it "sets the full name on the user and saves it" do
      existing_admin = FactoryGirl.create(:admin, email: "herman@example.com")

      expect(Admin.from_saml(auth).id).to eq existing_admin.id
      expect(existing_admin.reload.full_name).to eq "Herman Miller"
    end
  end
end
