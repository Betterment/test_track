class AdminSplitIndexPage < SitePrism::Page
  set_url '/admin'

  element :app_selector, 'select[data-testId="appSelector"]'

  section :splits_table, 'body.AdminSplits--index table' do
    elements :split_row, 'tbody tr'
  end

  element :log_out, 'a[href="/admins/sign_out"]'
end
