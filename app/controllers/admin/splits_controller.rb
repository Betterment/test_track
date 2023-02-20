class Admin::SplitsController < AuthenticatedAdminController
  def index
    if params[:app].present?
      @app = App.find_by(name: params[:app])
      return redirect_to admin_root_path unless @app

      @splits = @app.splits
    else
      @splits = Split.all
    end

    @splits = @splits.active.order(sort_field)
  end

  def show
    @split = Split.find(params[:id])
  end

  private

  def sort_field
    return :created_at if params[:sort] == 'date'

    :name
  end
end
