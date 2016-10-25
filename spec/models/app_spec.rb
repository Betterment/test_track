require 'rails_helper'

RSpec.describe App, type: :model do
  subject { FactoryGirl.build :app }

  describe "name" do
    it "validates presence of name" do
      expect(subject).to validate_presence_of(:name)
    end

    it "validates uniqueness of name" do
      expect(subject).to validate_uniqueness_of(:name)
    end
  end

  describe "auth_secret" do
    it "refuses to use a weak auth_secret" do
      subject.auth_secret = "puppy123"
      expect(subject).not_to be_valid
      expect(subject.errors).to be_added(:auth_secret, "must be at least 32-bytes, Base64 encoded")
    end

    it 'accepts a strong auth_secret' do
      subject.auth_secret = SecureRandom.urlsafe_base64(32)
      expect(subject).to be_valid
    end
  end
end
