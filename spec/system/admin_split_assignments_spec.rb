require 'rails_helper'

RSpec.describe 'show split assignments' do
  let(:split_page) { app.admin_split_show_page }
  let(:assignments_page) { app.admin_split_assignments_page }

  let(:split) { FactoryBot.create(:split) }
  let(:assignment_count) { 3 }
  let!(:assignments) do
    Assignment.transaction do
      identifiers = FactoryBot.create_list(:identifier, assignment_count)
      identifiers.map(&:visitor).map { |visitor| FactoryBot.create(:assignment, split:, visitor:) }
    end
  end

  before do
    login
  end

  it 'allows admins to view assignments' do
    split_page.load split_id: split.id

    expect(split_page.population_count).to have_content "3"
    split_page.population_count.click

    expect(assignments_page.assignments.length).to eq 3
  end

  context 'with too many assignments' do
    let(:assignment_count) { 1005 }

    it 'shows a limited number of assignments' do
      split_page.load split_id: split.id

      expect(split_page.population_count).to have_content "1005"
      split_page.population_count.click

      expect(assignments_page.assignments.length).to eq 1000
    end
  end
end
