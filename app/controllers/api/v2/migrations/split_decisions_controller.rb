class Api::V2::Migrations::SplitDecisionsController < AuthenticatedApiController
  def create
    split_decision = SplitDecisionMigration.new(create_params.merge(app: current_app))
    if split_decision.save
      head :no_content
    else
      render_errors split_decision
    end
  end

  private

  def create_params
    params.permit(:split, :variant)
  end
end
