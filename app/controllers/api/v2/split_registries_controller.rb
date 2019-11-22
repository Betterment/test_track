class Api::V2::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    build_timestamp = BuildTimestamp.new(build_params)
    if build_timestamp.valid?
      @split_registry = SplitRegistry.new(build_timestamp)
    else
      render_errors build_timestamp
    end

  end

  private

  def build_params
    params.permit(:timestamp)
  end
end
