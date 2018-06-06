class Api::V2::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    @split_registry = SplitRegistry.instance
  end
end
