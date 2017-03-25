class AdminSplitDecisionNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/decisions/new"

  section :create_form, "form" do
    element :variant_options, ".decision_variant"
    def select(text)
      variant_options.find('label.radio_buttons', text: text).click
    end
    element :submit_button, "input[name=commit]"
  end
end
