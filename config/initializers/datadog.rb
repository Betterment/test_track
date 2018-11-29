if ENV['DATADOG_ENABLED']
  require 'ddtrace'

  unless Rails.env.in?(%w(development test))
    service_name = Rails.application.class.parent_name.underscore

    Datadog.configure do |c|
      c.use :rails, service_name: service_name, distributed_tracing: true
      c.use :active_record, orm_service_name: "#{service_name}-active_record"
      c.use :delayed_job, service_name: "#{service_name}-delayed_job"
      c.use :http, service_name: "#{service_name}-http", distributed_tracing: true
    end
  end
end
