class Admin::DecisionsController < AuthenticatedAdminController
  def new
    @split = Split.find params[:split_id]
    @decision = @split.build_decision
  end

  def create
    split = Split.find params[:split_id]
    split.create_decision!(decision_params)
    flash[:success] = "Decided #{split.name} to #{params[:variant]}"
    redirect_to admin_split_path(split)
  end

  private

  def decision_params
    params.require(:decision).permit(:variant)
  end
end
