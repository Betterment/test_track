require 'rails_helper'

RSpec.describe AuthenticatedApiController, type: :controller do
  controller(AuthenticatedApiController) do
    def index
      head :ok
    end
  end

  let(:default_app) { FactoryGirl.create :app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOU" }

  describe "basic auth" do
    it "returns unauthorized when non-existent app" do
      http_authenticate username: 'foo', auth_secret: 'bar'

      get :index
      expect(response).to have_http_status :unauthorized
    end

    it "returns unauthorized when wrong auth_secret" do
      http_authenticate username: default_app.name, auth_secret: 'not_the_right_auth_secret'

      get :index
      expect(response).to have_http_status :unauthorized
    end

    it "allows access" do
      http_authenticate username: default_app.name, auth_secret: default_app.auth_secret

      get :index
      expect(response).to have_http_status :ok
    end
  end
end
