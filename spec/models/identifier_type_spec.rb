require 'rails_helper'

RSpec.describe IdentifierType do
  describe "#name" do
    it "validates presence of name" do
      expect(subject).to validate_presence_of(:name)
    end

    it "validates uniqueness of name" do
      expect(subject).to validate_uniqueness_of(:name)
    end

    it "rejects non-snake-case" do
      subject.name = 'fooBar'
      expect(subject).not_to be_valid
      expect(subject.errors[:name].first).to include("snake_case")
    end
  end

  describe "#owner_app" do
    it "validates presence of owner_app" do
      expect(subject).to validate_presence_of(:owner_app).with_message(:required)
    end
  end
end
