if ENV['DATADOG_ENABLED']
  require 'ddtrace'

  service_name = Rails.application.class.module_parent_name.underscore

  Datadog.configure do |c|
    c.agent.host = ENV.fetch('DD_AGENT_HOST', 'localhost')
    c.agent.port = ENV.fetch('DD_TRACE_AGENT_PORT', 8126)

    c.env = Rails.env
    c.version = ENV['GIT_COMMIT'] if ENV['GIT_COMMIT']

    c.service = service_name
    c.tracing.enabled = Rails.env.production? || ENV['DD_AGENT_HOST'].present?
    c.tracing.analytics.enabled = true

    c.tracing.instrument :rails, service_name:, distributed_tracing: true
    c.tracing.instrument :rack, service_name:, distributed_tracing: true, analytics_enabled: true
    c.tracing.instrument :active_record, service_name: "#{service_name}-active_record"
    c.tracing.instrument :delayed_job, service_name: "#{service_name}-delayed_job"
    c.tracing.instrument :http, service_name: "#{service_name}-http", distributed_tracing: true, analytics_enabled: true
    c.tracing.instrument :faraday, service_name: "#{service_name}-faraday", distributed_tracing: true
  end
end
