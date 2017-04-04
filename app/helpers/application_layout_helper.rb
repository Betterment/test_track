module ApplicationLayoutHelper
  def page_title
    content_for(:page_title) || 'Test Track Admin'
  end

  def site_layout_header_classes
    classes = ['sc-SiteLayout-header']
    classes << "sc-SiteLayout-header--#{header_modifier}"
    classes.join ' '
  end

  def site_layout_content_layout
    content_for(:site_content_layout) || 'base'
  end

  def header_modifier
    content_for(:header_modifier) || default_header_modifier
  end

  def default_header_modifier
    'blue'
  end

  def body_layout_body_color
    content_for(:body_layout_body_color) || 'nearWhite'
  end

  def body_layout_body_color_class
    "Body--#{body_layout_body_color}"
  end

  def site_layout_body_css_classes
    [controller_action_css_class, controller_css_class, body_layout_body_color_class].join(' ')
  end

  def controller_css_class
    controller_path.tr('/', '_').camelize
  end

  def controller_action_css_class
    "#{controller_css_class}--#{action_name}"
  end
end
