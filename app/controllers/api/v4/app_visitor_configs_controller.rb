class Api::V4::AppVisitorConfigsController < UnauthenticatedApiController
  include CorsSupport

  def show
    build_path = AppVersionBuildPath.new(build_params)
    if build_path.valid?
      app_build = build_path.app_build
      @active_splits = Split.for_presentation(app_build:)
      @visitor_id = visitor_id
      visitor = Visitor.find_or_initialize_by(id: @visitor_id)
      @assignments = visitor.assignments_for(app_build).includes(:split).order(:updated_at)
      @experience_sampling_weight = Rails.configuration.experience_sampling_weight
    else
      render_errors build_path
    end
  end

  private

  def build_params
    params.permit(:app_name, :version_number, :build_timestamp)
  end

  def visitor_id
    params.permit(:visitor_id).fetch(:visitor_id)
  end
end
