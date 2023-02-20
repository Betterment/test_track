class AdminBulkAssignmentNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/bulk_assignments/new"

  element :error_box, ".error"

  section :create_form, "form[data-testId='bulkAssignmentForm']" do
    element :identifiers_listing, "textarea#bulk_assignment_creation_identifiers_listing"
    element :identifier_creation_warning, "div#identifier_creation_warning"
    element :reason, "input#bulk_assignment_creation_reason"
    element :force_creation_checkbox, '[for=bulk_assignment_creation_force_identifier_creation]'

    section :identifier_type, '.IdentifierTypeSelection' do
      element :current, '.display-selected'
      element :select_element, '.select-options ul'

      def select(text)
        current.click
        select_element.find('li', text: text).click
      end
    end

    section :variant_options, ".fs-VariantOptions" do
      element :options, ' .radio-options'
      def select(text)
        options.find('li', text: text).click
      end
    end
    element :submit_button, "input[name=commit]"
  end
end
