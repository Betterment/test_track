class Admin::SplitSearchesController < AuthenticatedAdminController
  def create
    split = Split.find_by(name: params[:name])

    return redirect_to admin_split_path(split) if split

    flash[:error] = "No split with that name could be found."
    redirect_to admin_root_path
  end
end
