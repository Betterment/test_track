require 'rails_helper'

# The test environment raises exceptions instead of rendering error pages, so
# render them the way production does to check the statuses clients get.
RSpec.describe "Error pages" do
  around do |example|
    env_config = Rails.application.env_config
    original = env_config.slice('action_dispatch.show_exceptions', 'action_dispatch.show_detailed_exceptions')
    env_config['action_dispatch.show_exceptions'] = :all
    env_config['action_dispatch.show_detailed_exceptions'] = false
    example.run
  ensure
    env_config.merge!(original)
  end

  it "returns a 404 for unrouted paths" do
    get "/foo/bar"

    expect(response).to have_http_status :not_found
  end

  it "returns a 404 for unrouted paths requested as JSON" do
    get "/foo/bar.json", headers: { "Accept" => "application/json" }

    expect(response).to have_http_status :not_found
    expect(response.parsed_body).to eq("status" => 404, "error" => "Not Found")
  end
end
