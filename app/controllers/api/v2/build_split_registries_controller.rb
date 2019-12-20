class Api::V2::BuildSplitRegistriesController < UnauthenticatedApiController
  include CorsSupport

  def show
    snapshot = SplitRegistrySnapshot.new(timestamp: snapshot_params[:build_timestamp])

    if snapshot.valid?
      @split_registry_snapshot = snapshot
    else
      render_errors snapshot
    end
  end

  private

  def snapshot_params
    params.permit(:build_timestamp)
  end
end
