class Api::V1::IdentifierTypesController < AuthenticatedApiController
  def create
    identifier_type = IdentifierType.find_or_initialize_by(create_params.merge(owner_app: current_app))
    if identifier_type.save
      head :no_content
    else
      render_errors identifier_type
    end
  end

  private

  def create_params
    params.permit(:name)
  end
end
