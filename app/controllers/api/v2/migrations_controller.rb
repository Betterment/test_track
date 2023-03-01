class Api::V2::MigrationsController < AuthenticatedApiController
  def index
    @app_migrations = current_app.migrations.order(:version)
  end

  def create
    app_migration = current_app.migrations.find_or_initialize_by(create_params)
    if app_migration.save
      head :no_content
    else
      render_errors app_migration
    end
  end

  def destroy
    app_migration = current_app.migrations.find_or_initialize_by(version: params[:id])
    if app_migration.valid? && app_migration.destroy.destroyed?
      head :no_content
    else
      render_errors app_migration
    end
  end

  private

  def create_params
    params.permit(:version)
  end
end
