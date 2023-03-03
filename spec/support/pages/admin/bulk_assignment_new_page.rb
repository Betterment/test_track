class AdminBulkAssignmentNewPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/bulk_assignments/new"

  element :error_box, ".Banner--error"

  section :create_form, "form" do
    element :identifiers_listing, "textarea#bulk_assignment_creation_identifiers_listing"
    element :identifier_creation_warning, "div#identifier_creation_warning"
    element :reason, "input#bulk_assignment_creation_reason"
    element :force_creation_checkbox, '[for=bulk_assignment_creation_force_identifier_creation]'

    section :identifier_type, '.IdentifierTypeSelection' do
      element :field, 'select#bulk_assignment_creation_identifier_type_id'
    end

    section :variant_options, ".fs-VariantOptions" do
      element :options, ' .radio-options'
      def select(value)
        options.find("input[value=#{value}]").click
      end
    end
    element :submit_button, "input[name=commit]"
  end
end
