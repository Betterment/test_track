class Admin::SplitSearchesController < AuthenticatedAdminController
  def create
    split = Split.find_by(name: params[:name])

    return redirect_to admin_split_path(split) if split

    flash[:error] = t('split_searches.no_results')
    redirect_to admin_root_path
  end
end
