class Admin::DecisionsController < AuthenticatedAdminController
  def new
    @split = Split.find params[:split_id]
    @decision = Decision.new
  end

  def create
    split = Split.find params[:split_id]
    split.create_decision!(variant: target_variant)
    flash[:success] = "Decided #{split.name} to #{target_variant}"
    redirect_to admin_split_path(split)
  end

  private

  def target_variant
    params.require(:decision).permit(:variant).fetch(:variant)
  end
end
