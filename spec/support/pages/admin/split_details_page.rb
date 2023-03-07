class AdminSplitDetailsPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/details/edit"

  section :form, '.new_split_detail' do
    element :owner, "input[name='split_detail[owner]']"
    element :description, "textarea[name='split_detail[description]']"
    element :hypothesis, "textarea[name='split_detail[hypothesis]']"
    element :assignment_criteria, "textarea[name='split_detail[assignment_criteria]']"
    element :location, "input[name='split_detail[location]']"

    element :current_platform, '.split_detail_platform .display-selected'
    element :platform_dropdown, '.split_detail_platform select'
    def select_platform(text)
      platform_dropdown.select text
    end

    element :submit_button, 'input[type=submit]'
    def submit
      submit_button.click
    end
  end

  element :back_link, '.sc-TakeoverFooter-ctaBack'
end
