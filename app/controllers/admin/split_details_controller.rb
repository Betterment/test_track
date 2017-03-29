class Admin::SplitDetailsController < AuthenticatedAdminController
  def edit
    @split = Split.find params[:split_id]
  end

  def update
    @split = Split.find params[:split_id]
    if @split.update!(split_context_params)
      flash[:success] = "Successfully updated split test details."
      redirect_to admin_split_path(@split)
    else
      render :edit
    end
  end

  private

  def split_context_params
    params.require(:split).permit(:hypothesis, :assignment_criteria, :description, :owner)
  end
end
