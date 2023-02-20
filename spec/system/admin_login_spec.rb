require 'rails_helper'

RSpec.describe 'admin login' do
  subject { app.admin_split_index_page }

  let(:app_1) { FactoryBot.create :app }
  let(:app_2) { FactoryBot.create :app }

  let!(:split_1) { FactoryBot.create :split, owner_app: app_1 }
  let!(:split_2) { FactoryBot.create :split, owner_app: app_2 }

  it 'displays active splits page to authenticated admin' do
    login
    expect(subject).to be_loaded
    expect(subject.splits_table.split_row.count).to eq(2)

    subject.app_selector.select app_1.name
    expect(subject).to be_loaded
    expect(subject.splits_table.split_row.count).to eq(1)

    subject.app_selector.select app_2.name
    expect(subject).to be_loaded
    expect(subject.splits_table.split_row.count).to eq(1)

    subject.log_out.click
    expect(app.admin_session_new_page).to be_loaded
  end
end
