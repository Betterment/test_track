module RadioButton
  include ActionView::Helpers::OutputSafetyHelper

  def build_radio_button(options)
    value = options[:value]
    label = options[:label]
    completed = options[:state] == :completed

    if completed
      build_completed_button(value, label, options)
    else
      build_uncompleted_button(value, label, options)
    end
  end

  private

  def build_completed_button(value, label, options) # rubocop:disable Metrics/AbcSize
    description = options[:description]
    completed_css_class = description ? 'with-description completed' : 'completed'

    @builder.template.content_tag item_wrapper_tag, class: completed_css_class, data: { value: } do
      html = @builder.template.content_tag :div, class: "completed-radio-button" do
        template.content_tag :div, class: "radio-check" do
          @builder.template.content_tag(:img, nil, src: ActionController::Base.helpers.image_path('icons/checked_radio_button.svg'))
        end
      end
      html << add_label(label) << add_description(description, false)
    end
  end

  def build_uncompleted_button(value, label, options) # rubocop:disable Metrics/AbcSize
    selected = options[:state] == :selected || selected?(value)
    disabled = options[:state] == :disabled
    description = options[:description]
    css_class = css_class(selected, disabled)

    @builder.template.content_tag item_wrapper_tag, class: css_class, data: { value: } do
      html = @builder.template.content_tag :div, class: "radio-button #{value}" do
        template.radio_button(object_name, attribute_name, value, checked: selected, disabled:)
      end
      html << add_label(label) << add_description(description, disabled)
    end
  end

  def item_wrapper_tag_class
    'radio-option'
  end

  def item_wrapper_tag
    :li
  end

  def selected?(value)
    value == selected_option
  end

  def selected_option
    value = object.public_send(@attribute_name) if object
    if value.nil?
      options[:default]
    else
      value
    end
  end

  def add_label(label)
    @builder.template.content_tag(:label, label)
  end

  def add_description(description, disabled)
    if description
      @builder.template.content_tag(:div, description, class: description_class(disabled))
    else
      ActiveSupport::SafeBuffer.new
    end
  end

  def description_class(disabled)
    css_classes = ['radio-description']
    css_classes << 'pending' if disabled
    css_classes.join(' ')
  end

  def css_class(selected, disabled)
    css_classes = [item_wrapper_tag_class]
    css_classes << 'selected' if selected
    css_classes << 'disabled' if disabled
    css_classes.join(' ')
  end
end
