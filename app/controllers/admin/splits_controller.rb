class Admin::SplitsController < AuthenticatedAdminController
  def index
    @splits = Split.active
  end

  def show
    @split = Split.find params[:id]
  end
end
