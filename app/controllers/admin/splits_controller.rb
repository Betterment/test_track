class Admin::SplitsController < AuthenticatedAdminController
  def index
    @splits = Split.active.order(:name)
  end

  def show
    @split = SplitPresenter.new(Split.find(params[:id]))
  end
end
