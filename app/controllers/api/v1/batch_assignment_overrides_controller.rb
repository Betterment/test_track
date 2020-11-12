class Api::V1::BatchAssignmentOverridesController < SharedSecretAuthenticatedApiController
  include CorsSupport

  def create
    BatchArbitraryAssignmentCreation.create! create_params.merge(force: true)
    head :no_content
  end

  private

  def create_params
    params.permit(:visitor_id, assignments: %i(split_name variant context))
  end
end
