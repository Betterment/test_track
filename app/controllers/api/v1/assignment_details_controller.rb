class Api::V1::AssignmentDetailsController < AuthenticatedApiController
  def index
    @assignments = Visitor.find(params[:visitor_id]).assignments.by_recency.includes(:variant_details)
  end
end
