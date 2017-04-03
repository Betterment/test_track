class AdminSplitConfigNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/split_config/new"

  section :create_form, "form" do
    elements :weight_inputs, ".weight-input"
    element :submit_button, "input[name=commit]"
  end
end
