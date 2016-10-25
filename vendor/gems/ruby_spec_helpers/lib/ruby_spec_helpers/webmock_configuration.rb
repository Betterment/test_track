require 'webmock'
require 'webmock/rspec'

RSpec.configure do |config|
  config.before(:all) { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after(:all) { WebMock.allow_net_connect! }
  config.after(:each) { WebMock.reset! }
end
