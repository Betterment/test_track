class Api::V1::AssignmentEventsController < UnauthenticatedApiController
  include CorsSupport

  def create
    DeterministicAssignmentCreation.create! create_params
    head :no_content
  end

  private

  def create_params
    params.permit(:visitor_id, :split_name, :mixpanel_result, :context)
  end
end
