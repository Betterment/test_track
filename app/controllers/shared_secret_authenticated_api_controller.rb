require 'active_support/security_utils'

class SharedSecretAuthenticatedApiController < UnauthenticatedApiController
  SHARED_SECRET_ENV_VAR = 'BROWSER_EXTENSION_SHARED_SECRET'.freeze

  before_action :authenticate

  private

  def authenticate
    raise("#{SHARED_SECRET_ENV_VAR} not configured on TestTrack server!") unless shared_secret.present?

    authenticate_or_request_with_http_basic do |_username, candidate_shared_secret|
      ActiveSupport::SecurityUtils.secure_compare(shared_secret, candidate_shared_secret)
    end
  end

  def shared_secret
    ENV[SHARED_SECRET_ENV_VAR]
  end
end
