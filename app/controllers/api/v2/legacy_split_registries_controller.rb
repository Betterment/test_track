class Api::V2::LegacySplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    @split_registry = SplitRegistry.new(Time.zone.now)
  end
end
