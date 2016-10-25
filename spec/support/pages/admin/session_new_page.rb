class AdminSessionNewPage < SitePrism::Page
  set_url '/admins/sign_in'
  element :sign_in, '.login.saml'

  def submit
    sign_in.click
  end
end
