class Api::V3::SplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    snapshot = SplitRegistrySnapshot.new(timestamp: snapshot_params[:timestamp])

    if snapshot.valid?
      @split_registry_snapshot = snapshot
    else
      render_errors snapshot
    end
  end

  private

  def snapshot_params
    params.permit(:timestamp)
  end
end
