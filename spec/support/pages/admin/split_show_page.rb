class AdminSplitShowPage < SitePrism::Page
  set_url "/admin/splits/{split_id}"

  element :population_count, "tr.population-row span.population"

  element :change_weights, ".change-weights-link"
  element :add_details, ".add-details-link"
  element :decide_split, ".decide-split-link"
  element :upload_new_assignments, ".upload-new-assignments-link"

  section :test_overview, ".fs-SplitOverview" do
    element :table, ".DescriptionTable"
  end

  element :variants_table, ".fs-VariantsTable"
  sections :variants, ".fs-VariantsTable tbody tr" do
    element :name, 'td:nth-of-type(1)'
    element :description, 'td:nth-of-type(2)'
    element :weight, 'td:nth-of-type(3)'
    element :edit_link, 'td:nth-of-type(4) a'
  end
  def edit_variant(text)
    variants_table.find('tr', text: text).find('a').click
  end
end
