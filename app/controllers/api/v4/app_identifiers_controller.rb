class Api::V4::AppIdentifiersController < UnauthenticatedApiController
  include CorsSupport

  def create # rubocop:disable Metrics/MethodLength
    app_identifier_claim = AppIdentifierClaim.new(create_params)
    if app_identifier_claim.save
      visitor = app_identifier_claim.visitor
      app_build = app_identifier_claim.app_build
      @active_splits = Split.for_presentation(app_build: app_build)
      @visitor_id = visitor.id
      @assignments = visitor.assignments_for(app_build).includes(:split).order(:updated_at)
      @experience_sampling_weight = Rails.configuration.experience_sampling_weight
    else
      render_errors app_identifier_claim
    end
  end

  private

  def create_params
    params.permit(
      :app_name,
      :version_number,
      :build_timestamp,
      :identifier_type,
      :value,
      :visitor_id
    )
  end
end
