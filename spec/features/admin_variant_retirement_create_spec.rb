require 'rails_helper'

RSpec.describe 'admin can retire a variant for a split' do
  let(:split_page) { app.admin_split_show_page }

  let!(:split) { FactoryGirl.create :split, registry: { red: 25, blue: 0, green: 25, yellow: 25, orange: 25 } }

  before do
    FactoryGirl.create(:assignment, split: split, variant: :red)
    FactoryGirl.create(:assignment, split: split, variant: :green)
    FactoryGirl.create(:assignment, split: split, variant: :yellow)
    FactoryGirl.create_list(:assignment, 8, split: split, variant: :blue)

    login
  end

  it 'allows admins to retire a variant' do
    split_page.load split_id: split.id
    expect(split_page).to be_displayed
    expect(split_page.variants_table).to have_content "blue 0%(8) (Retire variant)"

    split_page.retire_variant.click

    expect(split_page.variants_table).to have_content "blue 0%(0)"
    expect(split_page.variants_table).not_to have_content "Retire variant"
  end
end
