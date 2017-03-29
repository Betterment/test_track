class AdminSplitDetailsPage < SitePrism::Page
  set_url "/admin/splits/{split_id}/details/edit"

  section :form, '.edit_split' do
    element :owner, "input[name='split[owner]']"
    element :description, "textarea[name='split[description]']"
    element :hypothesis, "textarea[name='split[hypothesis]']"
    element :assignment_criteria, "textarea[name='split[assignment_criteria]']"

    element :submit_button, 'input[type=submit]'
    def submit
      submit_button.click
    end
  end

  element :back_link, '.sc-TakeoverFooter-ctaBack'
end
