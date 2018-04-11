class Api::System::StatusesController < UnauthenticatedApiController
  def show
    render json: database_statuses, status: http_status
  end

  private

  def http_status
    all_databases_healthy? ? :ok : :service_unavailable
  end

  def all_databases_healthy?
    database_statuses.all? { |_db_name, db_status| db_status }
  end

  def database_statuses
    @database_statuses ||= {
      database: database_healthy?
    }
  end

  def database_healthy?(model_class = ActiveRecord::Base)
    model_class.connection.execute("select 1")
    true
  rescue StandardError
    false
  end
end
