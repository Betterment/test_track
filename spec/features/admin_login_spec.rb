require 'rails_helper'

RSpec.describe 'admin login' do
  subject { app.admin_split_index_page }

  it 'displays active splits to authenticated admin' do
    login
    expect(subject).to have_splits_table
  end
end
