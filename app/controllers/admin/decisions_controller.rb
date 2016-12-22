class Admin::DecisionsController < AuthenticatedAdminController
  def new
    @split = Split.find params[:split_id]
    @decision = Decision.new
  end

  def create
    split = Split.find params[:split_id]
    affected_assignments_count = split.assignments.where.not(variant: target_variant).count
    CreateDecisionJob.perform_later(split, variant: target_variant, admin: current_admin)
    flash[:success] = "Queued decision to reassign #{affected_assignments_count} visitors to #{target_variant}"
    redirect_to admin_split_path(split)
  end

  private

  def target_variant
    params.require(:decision).permit(:variant).fetch(:variant)
  end
end
