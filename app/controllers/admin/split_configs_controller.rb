class Admin::SplitConfigsController < AuthenticatedAdminController
  def new
    split = Split.find params[:split_id]
    @split_creation = split.build_split_creation
  end

  def create
    @split = Split.find params[:split_id]
    @split_creation = @split.build_split_creation(update_params)

    if @split_creation.save
      flash[:success] = "Changed Weights Successfully!"
      redirect_to admin_split_path(@split)
    else
      render :new
    end
  end

  private

  def update_params
    params.require(:split_creation).permit(weighting_registry: @split.registry.keys)
  end
end
