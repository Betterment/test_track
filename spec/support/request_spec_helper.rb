module RequestSpecHelper
  extend ActiveSupport::Concern

  included do
    let(:response_json) { JSON.parse(response.body) }
    let(:default_headers_or_env) { {} }
  end

  def http_authenticate(*args)
    opts = args.extract_options!
    username = (args.first || opts.delete(:username)).to_s || raise('Must provide a username')
    password = args[1] || opts.delete(:password) || 'password' # This is our conventional password for non-prod envs
    default_headers_or_env['REMOTE_ADDR'] = opts.delete(:remote_addr) || '127.0.0.8'
    default_headers_or_env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  # HACK: overriding the built-in request methods in order to provide some default header values
  # the set of methods was snatched from here.
  # https://github.com/rails/rails/blob/5-0-stable/actionpack/lib/action_dispatch/testing/integration.rb
  %w(
    get post patch put head delete
    xml_http_request xhr get_via_redirect post_via_redirect
  ).each do |method|
    define_method(method) do |path, opts = {}|
      opts[:headers] ||= {}
      opts[:headers] = opts[:headers].merge(default_headers_or_env)
      super(path, **opts)
    end
  end
end
