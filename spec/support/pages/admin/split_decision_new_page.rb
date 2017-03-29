class AdminSplitDecisionNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/decisions/new"

  section :create_form, "form" do
    element :variant_options, ".radio-options"
    def choose_variant_option(text)
      variant_options.find("input[value=#{text}]").click
    end
    element :submit_button, "input[name=commit]"
  end
end
