if ENV['DATADOG_ENABLED']
  require 'ddtrace'

  unless Rails.env.in?(%w(development test))
    service_name = Rails.application.class.parent_name.underscore

    Datadog.configure do |c|
      c.env = Rails.env

      c.tracer.hostname = ENV.fetch('DD_AGENT_HOST', 'localhost')
      c.tracer.port = ENV.fetch('DD_TRACE_AGENT_PORT', 8126)

      c.use :rails, service_name: service_name,
                    distributed_tracing: true

      c.use :rack, service_name: service_name,
                   distributed_tracing: true,
                   analytics_enabled: true

      c.use :active_record, orm_service_name: "#{service_name}-active_record"

      c.use :delayed_job, service_name: "#{service_name}-delayed_job"

      c.use :http, service_name: "#{service_name}-http",
                   distributed_tracing: true,
                   analytics_enabled: true

      c.use :faraday, service_name: "#{service_name}-faraday",
                      distributed_tracing: true
    end
  end
end
