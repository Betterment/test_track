class AdminSplitShowPage < SitePrism::Page
  set_url "/admin/splits/{split_id}"

  element :population_count, "tr.population-row span.population"
  element :update_assignments, "tr.population-row a"
  section :variants_table, "table.variants-table" do
    element :change_weights, "a.change-weights-link"
    element :retire_variant, "a.retire-variant-link"
  end
  element :decide_split, ".split-decision a"
end
