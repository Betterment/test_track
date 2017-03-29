require 'rails_helper'

RSpec.describe 'admin can add details to a split' do
  let(:split_page) { app.admin_split_show_page }
  let(:split_details_page) { app.admin_split_details_page }

  let!(:split) { FactoryGirl.create :split }

  let(:owner_name) { "Go Getters" }
  let(:description) { "We go and get" }
  let(:hypothesis) { "Users who like cheese will also like investing in cheese companies" }
  let(:assignment_criteria) { "Users must love cheese" }

  before do
    login
  end

  it 'allows admins to add details to a split' do
    split_page.load split_id: split.id
    expect(split_page).to be_displayed
    expect(split_page.test_overview).to have_content "Add metadata to your test"

    split_page.add_details.click
    expect(split_details_page).to be_displayed

    form = split_details_page.form
    form.owner.set owner_name
    form.description.set description
    form.hypothesis.set hypothesis
    form.assignment_criteria.set assignment_criteria
    form.submit

    expect(split_page).to be_displayed
    expect(split_page.test_overview.table).to have_content owner_name
    expect(split_page.test_overview.table).to have_content description
    expect(split_page.test_overview.table).to have_content hypothesis
    expect(split_page.test_overview.table).to have_content assignment_criteria
  end
end
