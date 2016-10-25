class ApplicationController < ActionController::Base
  def after_sign_out_path_for(resource_name)
    if resource_name == :admin
      admin_root_path
    else
      super
    end
  end
end
