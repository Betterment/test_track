class AdminSplitIndexPage < SitePrism::Page
  set_url '/admin'

  element :splits_table, 'body.splits.index table'
end
