class Api::V1::VariantDetailsController < AuthenticatedApiController
  def index
    @variant_details = Visitor.find(params[:visitor_id]).assignments.includes(:variant_details).map(&:variant_detail)
  end
end
