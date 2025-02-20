require 'rails_helper'

RSpec.describe 'admin can add details to a split' do
  let(:split_page) { app.admin_split_show_page }
  let(:split_details_page) { app.admin_split_details_page }

  let!(:feature_gate) { FactoryBot.create(:split, name: 'my_feature_enabled') }
  let!(:experiment) { FactoryBot.create(:split, name: 'my_experiment') }

  let(:owner_name) { "Go Getters" }
  let(:description) { "We go and get" }
  let(:platform) { "mobile" }
  let(:location) { "On the page that sells cheese" }
  let(:hypothesis) { "Users who like cheese will also like investing in cheese companies" }
  let(:assignment_criteria) { "Users must love cheese" }

  before do
    login
  end

  it 'allows admins to add basic details to a feature gate' do
    split_page.load split_id: feature_gate.id
    expect(split_page).to be_loaded
    expect(split_page.split_overview).not_to have_content "Is this split a test? Add metadata about it."

    split_page.edit_details.click
    expect(split_details_page).to be_loaded

    form = split_details_page.form
    form.owner.set owner_name
    form.select_platform platform
    form.location.set location
    form.submit

    expect(split_page).to be_loaded
    expect(split_page.split_overview.table).to have_content owner_name
    expect(split_page.split_overview.table).to have_content location
    expect(split_page.split_overview.table).to have_content platform
  end

  it 'allows admins to add experiment details to an experiment split' do
    split_page.load split_id: experiment.id
    expect(split_page).to be_loaded
    expect(split_page.experiment_details).to have_content "Is this split a test? Add metadata about it."

    split_page.add_experiment_details.click
    expect(split_details_page).to be_loaded

    form = split_details_page.form
    form.hypothesis.set hypothesis
    form.description.set description
    form.assignment_criteria.set assignment_criteria
    form.submit

    expect(split_page).to be_loaded
    expect(split_page.experiment_details.table).to have_content description
    expect(split_page.experiment_details.table).to have_content hypothesis
    expect(split_page.experiment_details.table).to have_content assignment_criteria
  end

  it 'permits blank values and forces a value if one exists' do
    split_page.load split_id: feature_gate.id
    expect(split_page).to be_loaded

    split_page.edit_details.click
    expect(split_details_page).to be_loaded

    form = split_details_page.form
    form.owner.set owner_name
    form.submit

    expect(split_page).to be_loaded
    expect(split_page.split_overview.table).to have_content owner_name

    split_page.edit_details.click
    expect(split_details_page).to be_loaded

    form = split_details_page.form
    form.owner.set ''
    form.submit

    expect(page).to have_content "can't be blank"
  end
end
