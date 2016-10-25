module ControllerSpecHelper
  extend ActiveSupport::Concern

  included do
    render_views
    let(:response_json) { JSON.parse(response.body) }
  end

  module ClassMethods
    def with_accept_header(type)
      before :each do
        request.headers['HTTP_ACCEPT'] = type
      end
    end
  end

  def http_authenticate(*args)
    opts = args.extract_options!
    username = (args.first || opts.delete(:username)).to_s || raise("Must provide a username")
    auth_secret = args[1] || opts.delete(:auth_secret) || "auth_secret"
    request.env['REMOTE_ADDR'] = opts.delete(:remote_addr) || "127.0.0.1"
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, auth_secret)
  end
end
