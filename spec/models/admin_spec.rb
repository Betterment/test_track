require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe ".from_saml" do
    let(:info) { { email: "herman@example.com", name: "Herman Miller" } }
    let(:auth) { OmniAuth::AuthHash.new(uid: "herman@example.com", info: info) }

    it "creates a user if one does not exist" do
      expect {
        admin = Admin.from_saml(auth)
        expect(admin.full_name).to eq "Herman Miller"
        expect(admin.email).to eq "herman@example.com"
        expect(admin.provider).to eq "SAML"
      }.to change { Admin.count }.by(1)
    end

    it "allows the user to log in despite casing" do
      FactoryBot.create :admin, email: "herman@example.com"
      expect {
        admin = Admin.from_saml(
          OmniAuth::AuthHash.new(
            uid: "Herman@example.com",
            info: {
              email: "Herman@example.com",
              name: "Herman Miller"
            }
          )
        )
        expect(admin.full_name).to eq "Herman Miller"
        expect(admin.email).to eq "herman@example.com"
        expect(admin.provider).to eq "SAML"
      }.not_to change { Admin.count }
    end

    it "sets the full name on the user and saves it" do
      existing_admin = FactoryBot.create(:admin, email: "herman@example.com")

      expect(Admin.from_saml(auth).id).to eq existing_admin.id
      expect(existing_admin.reload.full_name).to eq "Herman Miller"
    end
  end
end
