class Api::V2::Migrations::SplitsController < AuthenticatedApiController
  def create
    split_upsert = SplitUpsert.new(create_params.merge(app: current_app, require_app_name_prefix: true))
    if split_upsert.save
      head :no_content
    else
      render_errors split_upsert
    end
  end

  def destroy
    split = current_app.splits.find_by!(name: params[:id])
    split.update!(finished_at: Time.zone.now) unless split.finished?
    head :no_content
  end

  private

  def create_params
    # rails-sponsored workaround https://github.com/rails/rails/pull/12609
    params.permit(:name, weighting_registry: params[:weighting_registry].try(:keys))
  end
end
