require 'rails_helper'

describe Api::V1::VisitorDetailsController, type: :request do
  let(:default_app) { FactoryGirl.create(:app, name: 'default_app', auth_secret: '6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOf') }
  let(:split) { FactoryGirl.create(:split, name: 'excellent_feature', registry: { enabled: 50, disabled: 50 }, location: 'Home page') }

  let!(:variant_detail) do
    FactoryGirl.create(
      :variant_detail,
      split: split,
      variant: 'enabled',
      display_name: 'Awesome feature is on',
      description: 'This awesome feature makes cool stuff happen.'
    )
  end

  let(:identifier_type) { FactoryGirl.create(:identifier_type, name: 'crazy_id') }
  let(:visitor) { FactoryGirl.create(:visitor) }
  let!(:identifier) { FactoryGirl.create(:identifier, visitor: visitor, identifier_type: identifier_type, value: '3') }

  let!(:assignment) do
    FactoryGirl.create(
      :assignment,
      visitor: visitor,
      split: split,
      variant: 'enabled',
      created_at: Time.zone.parse('2017-04-05 14:00:00')
    )
  end

  before do
    http_authenticate username: default_app.name, password: default_app.auth_secret
  end

  describe 'GET /api/v1/identifier_types/:type/identifier/:id/visitor_details' do
    it 'renders a list of assignment details for the user' do
      get "/api/v1/identifier_types/crazy_id/identifiers/3/visitor_detail"

      expect(response_json['assignment_details'].count).to eq 1

      response_json['assignment_details'].first.tap do |assignment|
        expect(assignment['split_location']).to eq 'Home page'
        expect(assignment['split_name']).to eq 'excellent_feature'
        expect(assignment['variant_name']).to eq 'Awesome feature is on'
        expect(assignment['variant_description']).to eq 'This awesome feature makes cool stuff happen.'
        expect(assignment['assigned_at']).to eq '2017-04-05T14:00:00Z'
      end
    end
  end
end
