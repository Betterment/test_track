# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ScreenshotsController do
  let(:split) { FactoryBot.create(:split, name: 'my_split') }

  around do |example|
    env_config = Rails.application.env_config
    show_exceptions_was = env_config['action_dispatch.show_exceptions']
    show_detailed_exceptions_was = env_config['action_dispatch.show_detailed_exceptions']
    env_config['action_dispatch.show_exceptions'] = true
    env_config['action_dispatch.show_detailed_exceptions'] = false
    example.run
  ensure
    env_config['action_dispatch.show_exceptions'] = show_exceptions_was
    env_config['action_dispatch.show_detailed_exceptions'] = show_detailed_exceptions_was
  end

  describe 'GET /variant.ext' do
    it 'returns a 404' do
      get "/admin/splits/#{split.id}/screenshots/hammer_time.jpg"

      expect(response).to have_http_status(:not_found)
    end

    context 'when a variant detail record exists' do
      let!(:variant_detail) do
        FactoryBot.create(:variant_detail, split: split, variant: 'hammer_time')
      end

      it 'returns a 404' do
        get "/admin/splits/#{split.id}/screenshots/hammer_time.jpg"

        expect(response).to have_http_status(:not_found)
      end

      context 'when a screenshot exists' do
        before do
          variant_detail.screenshot_file_name = '1x1.jpg'
          variant_detail.screenshot_content_type = 'image/jpeg'
          variant_detail.screenshot_file_size = 123
          variant_detail.save!
        end

        it 'redirects to the screenshot' do
          get "/admin/splits/#{split.id}/screenshots/hammer_time.jpg"

          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(variant_detail.screenshot.url)
        end
      end
    end
  end
end
