class Api::V1::VisitorDetailsController < AuthenticatedApiController
  def show
    @assignments = VisitorLookup.new(index_params).visitor.assignments.includes(:variant_details)
  end

  private

  def index_params
    params.permit(:identifier_type_name, :identifier_value)
  end
end
