class Api::V2::Migrations::SplitRetirementsController < AuthenticatedApiController
  def create
    split_retirement = SplitRetirementMigration.new(create_params.merge(app: current_app))
    if split_retirement.save
      head :no_content
    else
      puts split_retirement.errors.full_messages
      render_errors split_retirement
    end
  end

  private

  def create_params
    params.permit(:split, :decision)
  end
end
