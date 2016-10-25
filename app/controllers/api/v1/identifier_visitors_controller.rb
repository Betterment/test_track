class Api::V1::IdentifierVisitorsController < UnauthenticatedApiController
  def show
    @visitor = VisitorLookup.new(show_params).visitor
  end

  private

  def show_params
    params.permit(:identifier_type_name, :identifier_value)
  end
end
