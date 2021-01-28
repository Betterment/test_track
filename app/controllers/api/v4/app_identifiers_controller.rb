class Api::V4::AppIdentifiersController < UnauthenticatedApiController
  include CorsSupport

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    build_path = AppVersionBuildPath.new(build_params)
    if build_path.valid?
      claim = IdentifierClaim.new(create_params)
      if claim.save!
        visitor = claim.identifier.visitor
        app_build = build_path.app_build
        @active_splits = Split.for_presentation(app_build: app_build)
        @visitor_id = visitor.id
        @assignments = visitor.assignments_for(app_build).includes(:split).order(:updated_at)
        @experience_sampling_weight = Rails.configuration.experience_sampling_weight
      else
        render_errors claim
      end
    else
      render_errors build_path
    end
  end

  private

  def build_params
    params.permit(:app_name, :version_number, :build_timestamp)
  end

  def create_params
    params.permit(:identifier_type, :value, :visitor_id)
  end
end
