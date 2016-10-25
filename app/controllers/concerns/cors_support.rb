module CorsSupport
  extend ActiveSupport::Concern

  included do
    after_action :set_cors_headers
  end

  private

  def set_cors_headers
    return unless cors_allowed?

    if preflight_request?
      add_preflight_cors_headers
    else
      add_cors_headers
    end
  end

  def cors_allowed?
    allowed_origins = whitelisted_hosts.split(',')
    allowed_origins.any? { |allowed_origin| origin.end_with?(allowed_origin) }
  end

  def whitelisted_hosts
    ENV['WHITELIST_CORS_HOSTS'] || raise("must provide ENV['WHITELIST_CORS_HOSTS']")
  end

  def origin
    request.headers['HTTP_ORIGIN'] || ''
  end

  def preflight_request?
    request.method == 'OPTIONS'
  end

  def add_preflight_cors_headers
    add_common_cors_headers
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS'
    headers['Access-Control-Allow-Headers'] = request.headers['ACCESS-CONTROL-REQUEST-HEADERS']
    headers['Access-Control-Max-Age'] = '3600'
  end

  def add_cors_headers
    add_common_cors_headers
  end

  def add_common_cors_headers
    headers['Access-Control-Allow-Origin'] = origin
    headers['Access-Control-Allow-Credentials'] = 'true'
  end
end
