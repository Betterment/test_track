module ApplicationLayoutHelper
  def page_title
    content_for(:page_title) || 'Test Track Admin'
  end

  def site_layout_header_classes
    classes = ['sc-SiteLayout-header']
    classes << "sc-SiteLayout-header--#{header_modifier}"
    classes.join ' '
  end

  def site_layout_section_classes
    classes = ['sc-SiteLayout-section']
    classes << "sc-SiteLayout-section--#{site_layout_body_color}" unless site_layout_body_color == 'white'
    classes.join ' '
  end

  def site_layout_container_classes
    classes = ['sc-SiteLayout-container']
    classes.join ' '
  end

  def content_layout_classes
    classes = ['sc-ContentLayout sc-ContentLayout--constrained']
    classes << 'sc-ContentLayout--centered' if site_layout_content_layout == 'centered'
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

  def site_layout_body_color
    content_for(:site_layout_body_color) || 'white'
  end

  def site_layout_body_css_classes
    [controller_action_css_class, controller_css_class].join(' ')
  end

  def controller_css_class
    controller_path.tr('/', '_').camelize
  end

  def controller_action_css_class
    "#{controller_css_class}--#{action_name}"
  end
end
