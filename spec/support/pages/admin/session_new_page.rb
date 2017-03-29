class AdminSessionNewPage < SitePrism::Page
  set_url '/admins/sign_in'
  element :sign_in, '.LoginCard-cta'

  def submit
    sign_in.click
  end
end
