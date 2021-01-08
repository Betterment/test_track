class Api::V2::Migrations::SplitsController < AuthenticatedApiController
  def create
    split_upsert = SplitUpsert.new(create_params.merge(app: current_app, require_app_name_prefix: true))
    if split_upsert.save
      head :no_content
    else
      puts split_upsert.errors.full_messages
      render_errors split_upsert
    end
  end

  private

  def create_params
    # rails-sponsored approach https://github.com/rails/rails/pull/12609
    params.permit(:name, weighting_registry: params[:weighting_registry].try(:keys)) # ensure weighting_registry is a hash of scalars
  end
end
