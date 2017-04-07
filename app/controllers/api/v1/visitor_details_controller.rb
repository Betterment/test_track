class Api::V1::VisitorDetailsController < AuthenticatedApiController
  def show
    @assignments = VisitorLookup.new(lookup_params).visitor.assignments.includes(:split, :variant_details)
  end

  private

  def lookup_params
    params.permit(:identifier_type_name, :identifier_value)
  end
end
