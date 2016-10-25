class Api::CorsController < UnauthenticatedApiController
  include CorsSupport

  def allow
    head :no_content
  end
end
