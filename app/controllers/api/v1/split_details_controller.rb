class Api::V1::SplitDetailsController < AuthenticatedApiController
  def show
    @split_detail = Split.find_by!(name: params[:id]).detail
  end
end
