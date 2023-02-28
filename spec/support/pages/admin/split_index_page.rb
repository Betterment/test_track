class AdminSplitIndexPage < SitePrism::Page
  set_url '/admin'

  element :filter_select, 'select[data-testId="appSelector"]'
  element :filter_submit, 'input[data-testId="filterFormSubmit"]'

  section :splits_table, 'body.AdminSplits--index table' do
    elements :split_row, 'tbody tr'
  end

  element :log_out, 'a[href="/admins/sign_out"]'
end
