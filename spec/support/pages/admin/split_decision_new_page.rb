class AdminSplitDecisionNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/decisions/new"

  section :create_form, "form[data-testId='splitDecisionForm']" do
    section :variant_options, ".fs-VariantOptions" do
      element :options, ' .radio-options'
      def select(text)
        options.find('li', text: text).click
      end
    end
    element :submit_button, "input[name=commit]"
  end
end
