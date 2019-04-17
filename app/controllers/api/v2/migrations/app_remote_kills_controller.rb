class Api::V2::Migrations::AppRemoteKillsController < AuthenticatedApiController
  def create
    remote_kill_migration = AppRemoteKillMigration.new(create_params.merge(app: current_app))
    if remote_kill_migration.save
      head :no_content
    else
      render_errors remote_kill_migration
    end
  end

  private

  def create_params
    params.permit(:split, :reason, :override_to, :first_bad_version, :fixed_version)
  end
end
