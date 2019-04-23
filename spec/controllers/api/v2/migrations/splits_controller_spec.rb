require 'rails_helper'

RSpec.describe Api::V2::Migrations::SplitsController do
  let(:default_app) { FactoryBot.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU" }

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
        post :create, params: { name: 'default_app.foobar', weighting_registry: { foo: 10, bar: 90 } }

        expect(response).to have_http_status(:no_content)
        split = Split.find_by(name: 'default_app.foobar', owner_app: default_app)
        expect(split).to be_truthy
        expect(split.registry).to eq 'foo' => 10, 'bar' => 90
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

    describe '#destroy' do
      it "sets the finished_at time on the split" do
        split = FactoryBot.create(:split, name: "default_app.old_split", owner_app: default_app, finished_at: nil)

        delete :destroy, params: { id: "default_app.old_split" }

        expect(response).to have_http_status(:no_content)
        expect(split.reload).to be_finished
      end

      it "can't delete another app's split" do
        other_app = FactoryBot.create :app, name: "other_app"
        split = FactoryBot.create(:split, name: "other_app.other_split", owner_app: other_app, finished_at: nil)

        expect { delete :destroy, params: { id: "other_app.other_split" } }.to raise_error(ActiveRecord::RecordNotFound)

        expect(split.reload).not_to be_finished
      end

      it "is idempotent" do
        split = FactoryBot.create(:split, name: "default_app.old_split", owner_app: default_app, finished_at: nil)

        Timecop.freeze(Time.zone.parse('2011-01-01')) do
          delete :destroy, params: { id: "default_app.old_split" }
        end

        expect(response).to have_http_status(:no_content)
        expect(split.reload.finished_at).to eq Time.zone.parse('2011-01-01')

        Timecop.freeze(Time.zone.parse('2011-01-02')) do
          delete :destroy, params: { id: "default_app.old_split" }
        end

        expect(response).to have_http_status(:no_content)
        expect(split.reload.finished_at).to eq Time.zone.parse('2011-01-01')
      end
    end
  end
end
