class AdminSplitShowPage < SitePrism::Page
  set_url "/admin/splits/{split_id}"

  element :population_count, "tr.population-row span.population"

  element :variants_table, '.variants-table'

  sections :variants, ".variants-table tbody tr" do
    element :edit_link, 'td:nth-of-type(4) a'
  end

  element :change_weights, ".change-weights-link"
  element :retire_variant, ".retire-variant-link"
  element :add_details, ".add-details-link"
  element :decide_split, ".decide-split-link"
  element :upload_new_assignments, ".upload-new-assignments-link"

  section :test_overview, ".TestOverview" do
    element :table, ".BasicTable"
  end
end
