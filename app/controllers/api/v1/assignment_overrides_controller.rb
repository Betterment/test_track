class Api::V1::AssignmentOverridesController < SharedSecretAuthenticatedApiController
  include CorsSupport

  def create
    ArbitraryAssignmentCreation.create! create_params
    head :no_content
  end

  private

  def create_params
    params.permit(:visitor_id, :split_name, :variant, :mixpanel_result, :context)
  end
end
