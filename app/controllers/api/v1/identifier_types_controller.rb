class Api::V1::IdentifierTypesController < AuthenticatedApiController
  def create
    identifier_type = IdentifierType.create_with(owner_app: current_app).find_or_initialize_by(create_params)
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
