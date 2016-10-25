class AdminSplitDecisionNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/decisions/new"

  section :create_form, "form" do
    element :variant, "select#decision_variant"
    element :submit_button, "input[name=commit]"
  end
end
