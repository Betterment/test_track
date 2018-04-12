require 'rails_helper'

RSpec.describe IdentifierClaim do
  describe "#save!" do
    let(:identifier_type) { FactoryBot.create(:identifier_type) }
    let(:visitor) { FactoryBot.create(:visitor) }

    let(:existing_identifier) { FactoryBot.create(:identifier, identifier_type: identifier_type, value: "foobar") }
    let(:existing_visitor) { existing_identifier.visitor }

    let(:unknown_uuid) { "ed33a00a-e10a-4c3f-b235-c529dfd8be8b" }

    context "validation" do
      let(:create_params) do
        { identifier_type: identifier_type.name, visitor_id: visitor.id, value: "123" }
      end

      it "is invalid if identifier_type is nil" do
        claim = IdentifierClaim.create! create_params.except(:identifier_type)
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:identifier_type, "can't be blank")
      end

      it "is invalid if visitor_id is nil" do
        claim = IdentifierClaim.create! create_params.except(:visitor_id)
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:visitor_id, "can't be blank")
      end

      it "is invalid if value is nil" do
        claim = IdentifierClaim.create! create_params.except(:value)
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:value, "can't be blank")
      end

      it "is invalid if identifier_type does not exist" do
        claim = IdentifierClaim.create! create_params.merge(identifier_type: "not_real_identifier_type")
        expect(claim).not_to be_valid
        expect(claim.errors).to be_added(:identifier_type, "does not exist")
      end
    end

    it "creates a new identifier linked to the visitor" do
      claim = IdentifierClaim.create!(identifier_type: identifier_type.name, visitor_id: visitor.id, value: "123")
      expect(claim.identifier).to be_persisted
      expect(claim.identifier.visitor).to eq visitor
    end

    it "creates a new visitor if none exits" do
      allow(Visitor).to receive(:new).and_call_original

      IdentifierClaim.create!(identifier_type: identifier_type.name, visitor_id: unknown_uuid, value: "123")

      expect(Visitor.where(id: unknown_uuid)).to be_present
    end

    it "returns the existing identifier with the same visitor if the visitor was already associated, without creating a new visitor" do
      existing_visitor
      allow(Visitor).to receive(:new).and_call_original

      claim = IdentifierClaim.create!(
        identifier_type: identifier_type.name,
        visitor_id: existing_visitor.id,
        value: existing_identifier.value
      )

      expect(Visitor).not_to have_received(:new)
      expect(claim.identifier).to eq existing_identifier
      expect(claim.identifier.visitor).to eq existing_visitor
    end

    it "doesn't create a new visitor when the incoming is identified and the target identity is claimed by another visitor" do
      FactoryBot.create(:identifier, visitor: visitor, identifier_type: identifier_type, value: "987")
      existing_visitor
      allow(Visitor).to receive(:new).and_call_original

      claim = IdentifierClaim.create!(
        identifier_type: identifier_type.name,
        visitor_id: visitor.id,
        value: existing_identifier.value
      )

      expect(Visitor).not_to have_received(:new)
      expect(claim.identifier).to be_persisted
      claim.identifier.visitor.tap do |v|
        expect(v).to eq existing_visitor
      end
    end

    it "creates a new visitor when the incoming visitor has another identifier of the same type" do
      existing_visitor
      allow(Visitor).to receive(:new).and_call_original

      claim = IdentifierClaim.create!(identifier_type: identifier_type.name, visitor_id: existing_visitor.id, value: "456")

      expect(Visitor).to have_received(:new)
      expect(claim.identifier).to be_persisted
      expect(claim.identifier.visitor).not_to eq existing_visitor

      VisitorSupersession.find_by!(
        superseded_visitor_id: existing_visitor.id,
        superseding_visitor_id: claim.identifier.visitor.id
      ).tap do |vs|
        expect(vs.superseded_visitor).to eq existing_visitor
        expect(vs.superseding_visitor).to eq claim.identifier.visitor
      end
    end

    it "creates a visitor supersession when the incoming is identified and the target identity is claimed by another visitor" do
      claim = IdentifierClaim.create!(visitor_id: visitor.id, identifier_type: identifier_type.name, value: existing_identifier.value)

      expect(claim.identifier).to be_persisted
      expect(claim.identifier.visitor).to eq existing_visitor

      VisitorSupersession.find_by!(
        superseded_visitor_id: visitor.id,
        superseding_visitor_id: claim.identifier.visitor.id
      ).tap do |vs|
        expect(vs.superseded_visitor).to eq visitor
        expect(vs.superseding_visitor).to eq claim.identifier.visitor
      end
    end

    it "finds existing visitor when there is a visitor creation race condition" do
      visitor
      error = ActiveRecord::RecordNotUnique.new("duplicate key value violates unique constraint")
      allow(Visitor).to receive(:find_or_create_by!).and_raise(error)

      claim = nil
      expect {
        claim = IdentifierClaim.create!(visitor_id: visitor.id, identifier_type: identifier_type.name, value: "123")
      }.to change { Visitor.count }.by(0)

      expect(claim.identifier.visitor).to eq visitor
    end

    it "finds an existing identifier when there is an identifier creation race condition" do
      FactoryBot.create(:identifier, visitor: visitor, identifier_type: identifier_type, value: "123")
      allow(Identifier).to receive(:find_by).and_return nil
      allow(Identifier).to receive(:create!) do
        allow(Identifier).to receive(:find_by).and_call_original
        raise ActiveRecord::RecordNotUnique, "duplicate key value violates unique constraint"
      end

      claim = nil
      expect {
        claim = IdentifierClaim.create!(visitor_id: visitor.id, identifier_type: identifier_type.name, value: "123")
      }.not_to change { Identifier.count }

      expect(claim.value).to eq "123"
    end
  end
end
