class Admin::DecisionsController < AuthenticatedAdminController
  def new
    @split = Split.find params[:split_id]
    @decision = Decision.new
  end

  def create
    @split = Split.find params[:split_id]
    Split.transaction do # FIXME: This makes sure this controller either succeeds or fails atomically until we can async the work
      @decision = @split.create_decision!(create_params)
    end
    flash[:success] = "Reassigned #{@decision.count} visitors to #{@decision.variant}"
    redirect_to admin_split_path(@split)
  end

  private

  def create_params
    create_form_params.merge(admin: current_admin, split: @split)
  end

  def create_form_params
    params.require(:decision).permit(:variant)
  end
end
