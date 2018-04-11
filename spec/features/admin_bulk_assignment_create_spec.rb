require 'rails_helper'

RSpec.describe 'bulk assign flow' do
  let(:split_page) { app.admin_split_show_page }
  let(:bulk_assignment_page) { app.admin_bulk_assignment_new_page }
  let(:user_id_values) { %w(4 8 15 16 23) }

  let!(:split) { FactoryBot.create :split }
  let!(:id_type_user_ids) { FactoryBot.create :identifier_type, name: "user_ids" }
  let!(:id_type_emails) { FactoryBot.create :identifier_type, name: "emails" }
  let!(:existing_identifiers) do
    user_id_values.map { |user_id| FactoryBot.create(:identifier, value: user_id, identifier_type: id_type_user_ids) }
  end

  before do
    login
  end

  def bulk_assign_to_hammer_time(identifiers_listing: '4, 8, 15, 16', identifier_type: 'user_ids')
    split_page.load split_id: split.id

    expect(split_page).to be_displayed
    expect(split_page.population_count.text).to eq "0"

    split_page.upload_new_assignments.click

    expect(bulk_assignment_page).to be_displayed

    bulk_assignment_page.create_form.tap do |form|
      form.identifiers_listing.set identifiers_listing
      form.identifier_type.select identifier_type
      form.variant_options.select 'hammer_time'
      form.reason.set "this is a test. a what? a test. a what? a test. oh a test."
      form.submit_button.click
    end
  end

  it 'allows admins to assign a split variant in bulk' do
    bulk_assign_to_hammer_time

    expect(split_page).to be_displayed

    Delayed::Worker.new.work_off

    expect(Assignment.count).to eq 4
    expect(BulkAssignment.count).to eq 1

    expect(Assignment.all.map(&:variant).uniq).to match_array %w(hammer_time)
    expect(Assignment.all.map { |a| a.bulk_assignment.id }.uniq).to match_array [BulkAssignment.first.id]
  end

  it 'warns admins when more than 2% of identifiers do not already exist' do
    bulk_assign_to_hammer_time(identifier_type: 'emails')

    expect(bulk_assignment_page.error_box).to have_content "Please address the errors below"
    expect(bulk_assignment_page.create_form.identifier_creation_warning).to have_content(
      <<~HTML
        100% (4 of 4) of the identifiers provided will be created as part of this operation.
        That's unusual. Please verify that you selected the correct Identified By below and
        double-check that the IDs listed above are correct. Do you still wish to proceed?
      HTML
    )

    bulk_assignment_page.create_form.identifier_type.select 'user_ids'
    bulk_assignment_page.create_form.submit_button.click

    expect(split_page).to be_displayed
  end

  it 'allows admins to ignore the warning and apply the bulk assignment' do
    bulk_assign_to_hammer_time(identifiers_listing: '4, 8, 15, 16, 23, 42', identifier_type: 'user_ids')

    expect(bulk_assignment_page.error_box).to have_content "Please address the errors below"
    expect(bulk_assignment_page.create_form.identifier_creation_warning).to have_content(
      <<~HTML
        17% (1 of 6) of the identifiers provided will be created as part of this operation.
        That's unusual. Please verify that you selected the correct Identified By below and
        double-check that the IDs listed above are correct. Do you still wish to proceed?
      HTML
    )

    bulk_assignment_page.create_form.force_creation_checkbox.click
    bulk_assignment_page.create_form.submit_button.click

    expect(split_page).to be_displayed
  end
end
