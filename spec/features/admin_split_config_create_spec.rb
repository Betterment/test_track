require 'rails_helper'

RSpec.describe 'admin can change weights for split variants' do
  let(:split_page) { app.admin_split_show_page }
  let(:split_config_new_page) { app.admin_split_config_new_page }

  let!(:split) { FactoryGirl.create :split, registry: { red: 100, blue: 0 } }
  let!(:identifier_type) { FactoryGirl.create :identifier_type, name: "ident_type_a" }

  before do
    login
  end

  it 'allows admins to change the weights of a split' do
    split_page.load split_id: split.id
    expect(split_page).to be_displayed
    expect(split_page.variants_table).to have_content "red 100% 0 blue 0% 0"

    split_page.change_weights.click

    expect(split_config_new_page).to be_displayed

    split_config_new_page.create_form.tap do |form|
      form.weight_inputs.each do |input|
        input.set 100
      end
      form.submit_button.click
    end
    expect(split_config_new_page).to have_content "must contain weights that sum to 100% (got 200)"

    # testing that we don't allow decimals, i.e. it truncates the inputs
    split_config_new_page.create_form.tap do |form|
      new_weights = %w(49.6 50.4)
      form.weight_inputs.each_with_index do |input, i|
        input.set new_weights[i]
      end
      form.submit_button.click
    end
    expect(split_config_new_page).to have_content "all weights must be integers"

    split_config_new_page.create_form.tap do |form|
      new_weights = %w(50 50)
      form.weight_inputs.each_with_index do |input, i|
        input.set new_weights[i]
      end
      form.submit_button.click
    end
    expect(split_page.variants_table).to have_content "red 50% 0 blue 50% 0"
  end
end
