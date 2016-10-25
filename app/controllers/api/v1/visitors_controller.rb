class Api::V1::VisitorsController < UnauthenticatedApiController
  include CorsSupport

  def show
    @visitor = Visitor.find_or_initialize_by(id: params[:id])
    @visitor.id = params[:id] unless @visitor.persisted?
  end
end
