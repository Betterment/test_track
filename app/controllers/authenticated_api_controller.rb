require 'active_support/security_utils'

class AuthenticatedApiController < UnauthenticatedApiController
  before_action :authenticate
  attr_reader :current_app

  def authenticate
    authenticate_or_request_with_http_basic do |app_name, auth_secret|
      app = App.find_by(name: app_name)
      if app && ActiveSupport::SecurityUtils.secure_compare(app.auth_secret, auth_secret)
        @current_app = app
      else
        head :unauthorized
      end
    end
  end
end
