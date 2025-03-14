class Admin::SplitDetailsController < AuthenticatedAdminController
  def edit
    @split_detail = Split.find(params[:split_id]).detail
  end

  def update
    @split_detail = Split.find(params[:split_id]).detail
    @split_detail.assign_attributes split_detail_params

    if @split_detail.save
      flash[:success] = "Successfully updated split test details."
      redirect_to admin_split_path(@split_detail.split)
    else
      render :edit
    end
  end

  private

  def split_detail_params
    params.fetch(:split_detail, {}).permit(
      :owner,
      :platform,
      :location,
      :control_variant,
      :start_date,
      :end_date,
      :description,
      :hypothesis,
      :assignment_criteria,
      :takeaways,
      :tests,
      :segments,
    )
  end
end
