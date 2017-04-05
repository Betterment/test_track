class Api::V1::SplitDetailsController < UnauthenticatedApiController
  include CorsSupport

  def show
    if split.present?
      @split_detail = SplitDetail.new(split: split)
    else
      render json: { error: "Split not found" }, status: :unprocessable_entity
    end
  end

  private

  def split
    @split ||= Split.find_by(name: params[:id])
  end
end
