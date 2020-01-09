class Api::V2::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    @split_registry = SplitRegistry.new(as_of: Time.zone.now)
  end
end
