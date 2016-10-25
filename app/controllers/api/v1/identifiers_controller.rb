class Api::V1::IdentifiersController < UnauthenticatedApiController
  include CorsSupport

  def create
    claim = IdentifierClaim.new(create_params)

    if claim.save!
      @identifier = claim.identifier
    else
      render_errors claim
    end
  end

  private

  def create_params
    params.permit(:identifier_type, :visitor_id, :value)
  end
end
