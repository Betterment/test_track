class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:saml]

  def saml
    verify_admin Admin.from_saml(request.env["omniauth.auth"])
  end

  # https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview#using-omniauth-without-other-authentications
  def new_session_path(_scope)
    new_admin_session_path
  end

  private

  def verify_admin(admin)
    @admin = admin

    if @admin&.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: @admin.provider if @admin.active_for_authentication?
      sign_in_and_redirect @admin, event: :authentication
    else
      flash[:error] = "Unable to sign in!"
      redirect_to new_admin_session_path
    end
  end
end
