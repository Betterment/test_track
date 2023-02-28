require 'rails_helper'

RSpec.describe VisitorLookup do
  subject { described_class.new(identifier_type_name: "clown_id", identifier_value: "1234") }
  let!(:identifier_type) { FactoryBot.create(:identifier_type, name: "clown_id") }

  describe "#visitor" do
    it "raises if the identifier_type cannot be found" do
      visitor_lookup = described_class.new(identifier_type_name: "pirate_id")
      expect { visitor_lookup.visitor }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns an existing identifier in the case of a race condition" do
      FactoryBot.create(:identifier, identifier_type: identifier_type, value: "1234")
      allow(Identifier).to receive(:find_or_create_by!).and_raise ActiveRecord::RecordNotUnique
      expect { subject.visitor }.not_to change { Identifier.count }
    end

    context "existing identifier" do
      let!(:identifier) { FactoryBot.create(:identifier, identifier_type: identifier_type, value: "1234") }

      it "does not create a new identifier or visitor" do
        expect { subject.visitor }
          .to not_change { Visitor.count }
          .and not_change { Identifier.count }
      end

      it "returns the visitor for the existing identifier" do
        expect(subject.visitor).to eq(identifier.visitor)
      end
    end

    context "non-existent identifier" do
      it "creates an identifier and a visitor" do
        expect { subject.visitor }
          .to change { Visitor.count }.by(1)
          .and change { Identifier.count }.by(1)
      end

      it "returns a new visitor connected to a new identifier for the given identifier_type" do
        visitor = subject.visitor
        identifier = visitor.identifiers.find_by!(value: "1234", identifier_type: identifier_type)

        expect(visitor).to eq(Visitor.first)
        expect(identifier).to eq(Identifier.first)
      end
    end
  end
end
