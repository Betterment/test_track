class AdminSplitShowPage < SitePrism::Page
  set_url "/admin/splits/{split_id}"

  element :population_count, "tr.population-row span.population"
  element :variants_table, "table.variants-table"

  element :change_weights, "a.change-weights-link"
  element :retire_variant, "a.retire-variant-link"
  element :add_details, "a.add-details-link"
  element :decide_split, "a.decide-split-link"
  element :upload_new_assignments, "a.upload-new-assignments-link"

  section :test_overview, ".TestOverview" do
    element :table, ".BasicTable"
  end
end
