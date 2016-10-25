class AuthenticatedAdminController < ApplicationController
  before_action :authenticate_admin!
end
