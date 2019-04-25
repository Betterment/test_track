require 'rails_helper'

RSpec.describe Api::V2::Migrations::SplitDecisionsController do
  let(:default_app) { FactoryBot.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU" }
  let!(:split) do
    FactoryBot.create(:split, owner_app: default_app, name: "default_app.my_split", registry: { a: 100, b: 0 }, finished_at: Time.zone.now)
  end

  describe '#create' do
    it "doesn't decide when unauthenticated" do
      post :create, params: { split: 'default_app.my_split', variant: "b" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(split.reload.finished_at).to be_present
    end
  end

  describe "while authenticated" do
    before do
      http_authenticate username: default_app.name, auth_secret: default_app.auth_secret
    end

    describe '#create' do
      it "decides a split to 100% desired weightings" do
        post :create, params: { split: 'default_app.my_split', variant: "b" }, as: :json

        expect(response).to have_http_status(:no_content)
        split.reload
        expect(split.registry).to eq 'a' => 0, 'b' => 100
        expect(split.decided_at).to be_present
        expect(split.finished_at).to eq nil
      end

      it 'returns errors when invalid' do
        post :create, params: { split: 'default_app.my_split', variant: "not_it" }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['errors']['variant'].first).to include("exist")
      end
    end
  end
end
