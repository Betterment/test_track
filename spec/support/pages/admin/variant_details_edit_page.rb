class AdminVariantDetailsEditPage < SitePrism::Page
  set_url '/admin/splits/{split_id}/variant_details/{variant}/edit'

  section :form, 'form[data-testId="variantDetailsEditForm"]' do
    element :display_name, 'input[name="variant_detail[display_name]"]'
    element :description, 'textarea[name="variant_detail[description]"]'
    element :screenshot, 'input[name="variant_detail[screenshot]"]'
    element :current_screenshot, '.variant_detail_screenshot .hint'
    element :retire_button, '.retire-variant-link'
    element :submit_button, 'input[type=submit]'
  end

  def retire_variant
    form.retire_button.click
  end
end
