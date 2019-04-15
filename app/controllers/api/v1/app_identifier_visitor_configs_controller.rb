class Api::V1::AppIdentifierVisitorConfigsController < UnauthenticatedApiController
  include CorsSupport

  def show
    app_build = AppVersionBuildPath.new(build_params).app_build
    @active_splits = Split.for_presentation(app_build: app_build)
    visitor = VisitorLookup.new(identifier_params).visitor
    @visitor = visitor.id
    @assignments = visitor.assignments_for(app_build).includes(:split).order(:updated_at)
  end

  private

  def build_params
    params.permit(:app_name, :version_number, :build_timestamp)
  end

  def identifier_params
    params.permit(:identifier_type_name, :identifier_value)
  end
end
