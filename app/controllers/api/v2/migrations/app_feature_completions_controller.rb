class Api::V2::Migrations::AppFeatureCompletionsController < AuthenticatedApiController
  def create
    feature_completion_migration = AppFeatureCompletionMigration.new(create_params.merge(app: current_app))
    if feature_completion_migration.save
      head :no_content
    else
      puts feature_completion_migration.errors.full_messages
      render_errors feature_completion_migration
    end
  end

  private

  def create_params
    params.permit(:feature_gate, :version)
  end
end
