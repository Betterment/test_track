require 'rails_helper'

RSpec.describe 'admin can edit variant details' do
  let(:split_page) { app.admin_split_show_page }
  let(:variant_page) { app.admin_variant_details_edit_page }

  let!(:split) { FactoryBot.create(:split, name: 'great_feature', registry: { enabled: 100, disabled: 0 }) }
  let(:variant_to_retire) { :disabled }

  let(:variant_screenshot) { Rails.root.join('spec', 'support', 'uploads', 'ttlogo.png') }

  before do
    FactoryBot.create_list(:assignment, 2, split: split, variant: variant_to_retire)
    login
  end

  it 'allows admins to edit variant details' do
    split_page.load split_id: split.id
    expect(split_page).to be_displayed

    expect(split_page.variants.count).to eq 2

    split_page.edit_variant(:enabled)
    expect(variant_page).to be_displayed
    expect(variant_page).not_to have_content "Retire variant"

    variant_page.form.display_name.set 'Variant name'
    variant_page.form.description.set 'Super great variant'
    variant_page.form.screenshot.set variant_screenshot
    variant_page.form.submit_button.click

    expect(split_page).to be_displayed
    expect(split_page).to have_content 'Details for enabled have been saved'
    expect(split_page.variants.first.name).to have_content "Variant name"
    expect(split_page.variants.first.description).to have_content "Super great variant"

    split_page.variants.first.edit_link.click
    expect(variant_page.form.current_screenshot).to have_content 'ttlogo.png'
  end

  context 'when a split variant can be retired' do
    it 'allows admins to retire variant details' do
      split_page.load split_id: split.id

      split_page.edit_variant(variant_to_retire)

      expect(variant_page).to be_displayed
      expect(variant_page).to have_content "Retire variant"
    end
  end
end
