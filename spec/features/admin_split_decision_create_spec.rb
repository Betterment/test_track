require 'rails_helper'

RSpec.describe 'split decision flow' do
  let(:split_page) { app.admin_split_show_page }
  let(:split_decision_page) { app.admin_split_decision_new_page }
  let(:user_id_values) { %w(4 8 15 16 23) }
  let!(:split) { FactoryGirl.create :split }
  let!(:id_type_user_ids) { FactoryGirl.create :identifier_type, name: "user_ids" }

  let!(:existing_identifiers) do
    user_id_values.map { |user_id| FactoryGirl.create(:identifier, value: user_id, identifier_type: id_type_user_ids) }
  end
  let!(:existing_assignments) do
    existing_identifiers.map do |identifier|
      FactoryGirl.create(:assignment, visitor: identifier.visitor, split: split, variant: "hammer_time")
    end
  end

  before do
    login
  end

  it 'allows an admin to decide a split' do
    split_page.load split_id: split.id
    expect(split_page).to be_displayed

    expect(Assignment.where(variant: "hammer_time").count).to eq 5
    expect(Assignment.where(variant: "touch_this").count).to eq 0

    split_page.decide_split.click
    expect(split_decision_page).to be_displayed

    split_decision_page.create_form.tap do |form|
      form.variant.select 'touch_this'
      form.submit_button.click
    end

    expect(split_page).to be_displayed
    expect(split_page).to have_content "Queued decision"

    Delayed::Worker.new.work_off

    split_page.load split_id: split.id
    expect(split_page).to be_displayed

    expect(Assignment.where(variant: "hammer_time").count).to eq 0
    expect(Assignment.where(variant: "touch_this").count).to eq 5

    split.reload
    expect(split.registry).to eq("hammer_time" => 0, "touch_this" => 100)
  end
end
