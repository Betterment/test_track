class Admin::VariantDetailsController < AuthenticatedAdminController
  def edit
    @split = Split.find(params[:split_id])
    @variant_detail = @split.variant_details.find_or_initialize_by(variant: params[:id])
  end

  def update
    @split = Split.find(params[:split_id])
    @variant_detail = @split.variant_details.find_or_initialize_by(variant: params[:id])

    if @variant_detail.update update_params
      flash[:success] = "Details for #{@variant_detail.variant} have been saved."
      redirect_to admin_split_path(@split)
    else
      render :edit
    end
  end

  private

  def update_params
    params.require(:variant_detail).permit(:display_name, :description, :screenshot)
  end
end
