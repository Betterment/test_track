class Api::V1::SplitDetailsController < AuthenticatedApiController
  def show
    if split.present?
      @split_detail = SplitDetail.new(split: split)
    else
      render json: { error: "Split not found" }, status: :not_found
    end
  end

  private

  def split
    @split ||= Split.find_by(name: params[:id])
  end
end
