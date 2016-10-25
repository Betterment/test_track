module SitePrismDropdown
  extend ActiveSupport::Concern

  module ClassMethods
    def dropdown(dropdown_name, *find_args)
      section dropdown_name, *find_args do
        element :current, "button"
        element :menu, "ul.dropdown-menu"

        def select(text)
          self.current.click
          self.menu.find("li a", :text => text).click
        end
      end
    end
  end
end
