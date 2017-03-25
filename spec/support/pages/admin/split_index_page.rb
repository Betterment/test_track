class AdminSplitIndexPage < SitePrism::Page
  set_url '/admin'

  element :splits_table, 'body.AdminSplits--index table'
  element :log_out, '.sc-TakeoverHeader-multiple-cta a[href="/admins/sign_out"]'
end
