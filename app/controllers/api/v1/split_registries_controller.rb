class Api::V1::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    @active_splits = Split.active
  end
end
