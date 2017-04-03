class Admin::SplitDetailsController < AuthenticatedAdminController
  def new
    @split_detail = SplitDetail.new split_detail_create_params.merge(split: Split.find(params[:split_id]))
  end

  def create
    @split_detail = SplitDetail.new split_detail_create_params.merge(split: Split.find(params[:split_id]))

    if @split_detail.save
      flash[:success] = "Successfully updated split test details."
      redirect_to admin_split_path(@split_detail.split)
    else
      render :new
    end
  end

  private

  def split_detail_create_params
    params.fetch(:split_detail, {}).permit(:hypothesis, :assignment_criteria, :description, :owner, :location, :platform)
  end
end
