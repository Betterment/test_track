class AdminSplitIndexPage < SitePrism::Page
  set_url '/admin'

  element :splits_table, 'body.splits.index table'
  element :log_out, '.performer-nav a[href="/admins/sign_out"]'
end
