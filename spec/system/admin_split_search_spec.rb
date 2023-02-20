require 'rails_helper'

RSpec.describe 'admin split search' do
  subject { app.admin_split_index_page }
  let(:split_page) { app.admin_split_show_page }

  let(:app_1) { FactoryBot.create :app }
  let(:app_2) { FactoryBot.create :app }

  let!(:split_1) { FactoryBot.create :split, owner_app: app_1 }
  let!(:split_2) { FactoryBot.create :split, owner_app: app_2 }

  it 'supports searching for a split' do
    login

    expect(subject).to be_loaded

    subject.find('input[data-testId="splitSearch"]').set("#{split_1.name}\n")

    expect(split_page).to be_loaded
    expect(split_page).to have_content(split_1.name)
  end
end
