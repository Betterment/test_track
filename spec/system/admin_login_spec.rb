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

  context 'if GITHUB_ORGANIZATION ENV is set' do
    let!(:split) { FactoryBot.create(:split, name: 'test_split') }

    before do
      ENV['GITHUB_ORGANIZATION'] = 'test'
    end

    it 'displays Github search link' do
      login

      expect(subject).to have_text("Github")
    end
  end
end
