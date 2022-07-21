require 'rails_helper'

RSpec.describe 'admin login' do
  subject { app.admin_split_index_page }

  it 'displays active splits to authenticated admin' do
    login
    expect(subject).to be_loaded
    expect(subject).to have_splits_table
    subject.log_out.click
    expect(app.admin_session_new_page).to be_loaded
  end
end
