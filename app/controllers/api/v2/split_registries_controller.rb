class Api::V2::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    @split_registry = SplitRegistrySnapshot.new(timestamp: Time.zone.now)
  end
end
