class Admin::DecisionsController < AuthenticatedAdminController
  def new
    @split = Split.find params[:split_id]
    @decision = Decision.new
  end

  def create
    split = Split.find params[:split_id]
    decision = split.build_decision(create_params)
    CreateDecisionJob.perform_later(split, create_params)
    flash[:success] = "Queued decision to reassign #{decision.count} visitors to #{decision.variant}"
    redirect_to admin_split_path(split)
  end

  private

  def create_params
    create_form_params.merge(admin: current_admin)
  end

  def create_form_params
    params.require(:decision).permit(:variant)
  end
end
