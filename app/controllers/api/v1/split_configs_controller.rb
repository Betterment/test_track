class Api::V1::SplitConfigsController < AuthenticatedApiController
  def create
    split_creation = SplitCreation.new(create_params.merge(app: current_app))
    if split_creation.save
      head :no_content
    else
      render_errors split_creation
    end
  end

  def destroy
    split = Split.find_by!(name: params[:id])
    split.update!(finished_at: Time.zone.now) unless split.finished?
    head :no_content
  end

  private

  def create_params
    # rails-sponsored workaround https://github.com/rails/rails/pull/12609
    params.permit(:name, weighting_registry: params[:weighting_registry].try(:keys))
  end
end
