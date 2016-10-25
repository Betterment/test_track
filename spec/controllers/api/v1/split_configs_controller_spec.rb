require 'rails_helper'

RSpec.describe Api::V1::SplitConfigsController, type: :controller do
  let(:default_app) { FactoryGirl.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU" }

  before do
    http_authenticate username: default_app.name, auth_secret: default_app.auth_secret
  end

  describe '#create' do
    it "creates a new split with desired weightings" do
      post :create, name: 'foobar', weighting_registry: { foo: 10, bar: 90 }

      expect(response).to have_http_status(:no_content)
      split = Split.find_by(name: 'foobar', owner_app: default_app)
      expect(split).to be_truthy
      expect(split.registry).to eq 'foo' => 10, 'bar' => 90
    end

    it 'returns errors when invalid' do
      post :create, name: 'fooBar', weighting_registry: { foo: 10, bar: 90 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']['name'].first).to include("snake_case")
    end
  end

  describe '#destroy' do
    it "sets the finished_at time on the split" do
      split = FactoryGirl.create(:split, name: "old_split", owner_app: default_app, finished_at: nil)

      delete :destroy, id: "old_split"

      expect(response).to have_http_status(:no_content)
      expect(split.reload).to be_finished
    end

    it "is idempotent" do
      split = FactoryGirl.create(:split, name: "old_split", owner_app: default_app, finished_at: nil)

      Timecop.freeze(Time.zone.parse('2011-01-01')) do
        delete :destroy, id: "old_split"
      end

      expect(response).to have_http_status(:no_content)
      expect(split.reload.finished_at).to eq Time.zone.parse('2011-01-01')

      Timecop.freeze(Time.zone.parse('2011-01-02')) do
        delete :destroy, id: "old_split"
      end

      expect(response).to have_http_status(:no_content)
      expect(split.reload.finished_at).to eq Time.zone.parse('2011-01-01')
    end
  end
end
