class AdminVariantDetailsEditPage < SitePrism::Page
  set_url '/admin/splits/{split_id}/variant_details/{variant}/edit'

  section :form, 'form' do
    element :display_name, 'input[name="variant_detail[display_name]"]'
    element :description, 'textarea[name="variant_detail[description]"]'
    element :screenshot, 'input[name="variant_detail[screenshot]"]'
    element :current_screenshot, '.variant_detail_screenshot .hint'
    element :submit_button, 'input[type=submit]'
  end
end
