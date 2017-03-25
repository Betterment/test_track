module ApplicationLayoutHelper
  def page_title
    content_for(:page_title) || 'Test Track Admin'
  end

  def body_css_classes
    [controller_action_css_class, controller_css_class].join(' ')
  end

  def controller_css_class
    controller_path.tr('/', '_').camelize
  end

  def controller_action_css_class
    "#{controller_css_class}--#{action_name}"
  end
end
