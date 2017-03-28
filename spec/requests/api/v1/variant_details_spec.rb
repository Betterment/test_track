require 'rails_helper'

describe Api::V1::VariantDetailsController, type: :request do
  let(:split) { FactoryGirl.create(:split, name: 'excellent_feature', registry: { enabled: 50, disabled: 50 }) }

  let!(:variant_detail) do
    FactoryGirl.create(
      :variant_detail,
      split: split,
      variant: 'enabled',
      display_name: 'Awesome feature is on',
      description: 'This awesome feature makes cool stuff happen.'
    )
  end

  let(:visitor) { FactoryGirl.create(:visitor) }
  let!(:assignment) { FactoryGirl.create(:assignment, visitor: visitor, split: split, variant: 'enabled') }

  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /api/v1/visitors/:id/variant_details' do
    it 'renders a list of variant details for the user' do
      get "/api/v1/visitors/#{visitor.id}/variant_details"

      expect(response_json.count).to eq 1

      response_json.first.tap do |variant|
        expect(variant['display_name']).to eq 'Awesome feature is on'
        expect(variant['description']).to eq 'This awesome feature makes cool stuff happen.'
      end
    end
  end
end
