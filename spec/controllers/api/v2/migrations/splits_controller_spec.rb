require 'rails_helper'

RSpec.describe Api::V2::Migrations::SplitsController do
  let(:default_app) { FactoryBot.create(:app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU") }

  describe '#create' do
    it "doesn't create when unauthenticated" do
      post :create, params: { name: 'default_app.foobar', weighting_registry: { foo: 10, bar: 90 } }

      expect(response).to have_http_status(:unauthorized)
      expect(Split.where(name: 'default_app.foobar')).to be_empty
    end
  end

  describe "while authenticated" do
    before do
      http_authenticate username: default_app.name, auth_secret: default_app.auth_secret
    end

    describe '#create' do
      it "creates a new split with desired weightings" do
        post :create, params: { name: 'default_app.foobar', owner: 'test-owner', weighting_registry: { foo: 10, bar: 90 } }

        expect(response).to have_http_status(:no_content)
        split = Split.find_by(name: 'default_app.foobar', owner_app: default_app)
        expect(split).to be_truthy
        expect(split.registry).to eq 'foo' => 10, 'bar' => 90
        expect(split.owner).to eq 'test-owner'
      end

      it "does not remove ownership from an existing split if the variable is missing" do
        split = Split.create(name: 'default_app.foobar', owner: 'test-owner', owner_app: default_app)
        expect(split.owner).to eq 'test-owner'

        expect {
          post :create, params: { name: 'default_app.foobar', weighting_registry: { foo: 10, bar: 90 } }
          expect(response).to have_http_status(:no_content)
        }.to not_change{ split.owner }.from('test-owner')
      end

      it 'returns errors when invalid' do
        post :create, params: { name: 'default_app.fooBar', weighting_registry: { foo: 10, bar: 90 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']['name'].first).to include("snake_case")
      end

      it "is invalid with a non-prefixed name" do
        post :create, params: { name: 'foobar', weighting_registry: { foo: 10, bar: 90 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']['name'].first).to include("prefix")
      end
    end
  end
end
