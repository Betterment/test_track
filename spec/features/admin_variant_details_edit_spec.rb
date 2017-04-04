require 'rails_helper'

RSpec.describe 'admin can edit variant details' do
  let(:split_page) { app.admin_split_show_page }
  let(:variant_page) { app.admin_variant_details_edit_page }

  let!(:split) { FactoryGirl.create(:split, name: 'great_feature', registry: { enabled: 100 }) }

  before do
    login
  end

  it 'allows admins to edit variant details' do
    split_page.load split_id: split.id
    expect(split_page).to be_displayed

    expect(split_page.variants.count).to eq 1
    split_page.variants.first.edit_link.click

    expect(variant_page).to be_displayed

    variant_page.form.display_name.set 'Variant name'
    variant_page.form.description.set 'Super great variant'
    variant_page.form.submit_button.click

    expect(split_page).to be_displayed
    expect(split_page).to have_content 'Details for enabled have been saved'
  end
end
