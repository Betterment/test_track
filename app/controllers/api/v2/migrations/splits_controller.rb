class Api::V2::Migrations::SplitsController < AuthenticatedApiController
  def create
    split_upsert = SplitUpsert.new(create_params.merge(app: current_app, require_app_name_prefix: true))
    if split_upsert.save
      head :no_content
    else
      render_errors split_upsert
    end
  end

  private

  def create_params
    params.permit(
      :name,
      :owner,
      weighting_registry: params[:weighting_registry].try(:keys),  # ensure weighting_registry is a hash of scalars
    )
  end
end
