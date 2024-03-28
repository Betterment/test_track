require 'rails_helper'

RSpec.describe Admin::SplitsController do
  include Warden::Test::Helpers

  describe 'GET /admin' do
    let(:default_app) { FactoryBot.create(:app, name: "default_app", auth_secret: "6Sd6T7T6Q8hKcoo0t8CTzV0IdN1EEHqXB2Ig4raZsOf") }
    let(:admin) { FactoryBot.create(:admin) }
    let(:deployment_env_label) { 'Stage Environment' }
    let(:banner_tag) { "<p class=\"banner-text\">" }

    before do
      login_as admin
    end

    context 'when no DEPLOYMENT_ENV_LABEL is set' do
      it 'renders without environment label banner' do
        get '/admin'

        expect(response).to have_http_status :ok

        expect(response.body).not_to include(banner_tag)
        expect(response.body).not_to include(deployment_env_label)
      end
    end

    context 'when DEPLOYMENT_ENV_LABEL is set' do
      around do |example|
        with_env DEPLOYMENT_ENV_LABEL: deployment_env_label do
          example.run
        end
      end

      it 'renders with environment label banner' do
        get '/admin'

        expect(response).to have_http_status :ok

        expect(response.body).to include(banner_tag)
        expect(response.body).to include(deployment_env_label)
      end
    end
  end
end
