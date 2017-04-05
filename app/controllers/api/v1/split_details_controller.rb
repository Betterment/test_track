class Api::V1::SplitDetailsController < AuthenticatedApiController
  def show
    @split_detail = SplitDetail.new(split: Split.find_by!(name: params[:id]))
  end
end
