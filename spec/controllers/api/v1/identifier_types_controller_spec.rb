require 'rails_helper'

RSpec.describe Api::V1::IdentifierTypesController, type: :controller do
  let(:default_app) { FactoryBot.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU" }

  it 'requires http basic auth' do
    http_authenticate username: default_app.name, auth_secret: 'bad bad bad'
    post :create
    expect(response).to have_http_status :unauthorized
  end

  describe "#create" do
    before { http_authenticate username: default_app.name, auth_secret: default_app.auth_secret }

    it "creates a new identifier type" do
      post :create, params: { name: 'myappdb_user_id' }
      expect(response).to have_http_status(:no_content)
      expect(IdentifierType.find_by(name: 'myappdb_user_id', owner_app: default_app)).to be_truthy
    end

    it 'is idempotent for existing identifier types' do
      FactoryBot.create :identifier_type, owner_app: default_app, name: 'myappdb_user_id'

      expect { post :create, params: { name: 'myappdb_user_id' } }.not_to change { IdentifierType.count }
      expect(response).to have_http_status(:no_content)
      expect(IdentifierType.find_by!(name: 'myappdb_user_id', owner_app: default_app)).to be_truthy
    end

    it 'returns errors when invalid' do
      post :create, params: { name: 'myappdbUserId' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']['name'].first).to include("snake_case")
    end
  end
end
