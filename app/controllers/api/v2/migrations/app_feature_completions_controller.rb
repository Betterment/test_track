class Api::V2::Migrations::AppFeatureCompletionsController < AuthenticatedApiController
  def create
    feature_gate = Split.find_by(name: create_params[:feature_gate])
    feature_completion = current_app.feature_completions.find_or_initialize_by(
      feature_gate: feature_gate,
      version: AppVersion.new(create_params[:version])
    )
    if feature_completion.save
      head :no_content
    else
      render_errors feature_completion
    end
  end

  private

  def create_params
    params.permit(:feature_gate, :version)
  end
end
