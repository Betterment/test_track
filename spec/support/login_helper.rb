module LoginHelper
  def init_omniauth(email = 'filbert@example.com')
    OmniAuth.config.mock_auth[:saml] = OmniAuth::AuthHash.new(
      uid: email,
      info: {
        name: 'name'
      }
    )
  end

  def login
    init_omniauth
    app.admin_session_new_page.load
    app.admin_session_new_page.submit
    expect(app.admin_split_index_page).to be_displayed
  end
end
