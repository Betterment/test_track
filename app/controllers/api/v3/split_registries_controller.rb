class Api::V3::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    split_registry = SplitRegistry.new(as_of: split_registry_params[:build_timestamp])

    if split_registry.valid?
      @split_registry = split_registry
    else
      render_errors split_registry
    end
  end

  private

  def split_registry_params
    params.permit(:build_timestamp)
  end
end
