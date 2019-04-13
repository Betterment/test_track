class Api::V2::MigrationsController < AuthenticatedApiController
  def create
    app_migration = current_app.migrations.find_or_initialize_by(create_params)
    if app_migration.save
      head :no_content
    else
      render_errors app_migration
    end
  end

  def index
    @app_migrations = current_app.migrations.order(:version)
  end

  private

  def create_params
    params.permit(:version)
  end
end
