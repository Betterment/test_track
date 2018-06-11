class CollectionSelectInput < SimpleForm::Inputs::CollectionSelectInput
  include ActionView::Helpers::OutputSafetyHelper

  def display_dropdown(_wrapper_options) # rubocop:disable Metrics/AbcSize
    # unclear what the desired behavior would be if both of these options are set
    raise 'You can only use one of :include_blank/:prompt' if options[:include_blank] && options[:prompt]

    @builder.template.content_tag :ul do
      dropdown_options = collection.map do |option|
        label, value = option_label_value option

        @builder.template.content_tag(:li, label, class: 'selectable', data: { value: value })
      end

      dropdown_options.unshift(blank_option_tag) if blank_option_label
      safe_join dropdown_options
    end
  end

  def input(wrapper_options)
    label_method, value_method = collection_methods

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, merged_input_options
    )
  end

  def selected(_wrapper_options)
    if options[:selected].present?
      provided_selected_option_label
    elsif selected_option_label.present?
      selected_option_label
    else
      blank_option_label || extract_label(collection.first)
    end
  end

  private

  def provided_selected_option_label
    extract_label find_selected(options[:selected])
  end

  def selected_option_label
    extract_label find_selected(object.public_send(@attribute_name))
  end

  def find_selected(value)
    collection.find do |option|
      extract_from_option(option, value_method) == value || option == value
    end
  end

  def blank_option_label
    if prompt?
      prompt_as_string
    elsif include_blank?
      include_blank_as_string
    end
  end

  def blank_option_tag
    @builder.template.content_tag(:li, blank_option_label, class: 'selectable', data: { value: '' })
  end

  def label_method
    collection_methods.first
  end

  def value_method
    collection_methods.second
  end

  def collection_methods
    @_collection_methods ||= detect_collection_methods # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def extract_label(option)
    extract_from_option(option, label_method)
  end

  def extract_from_option(option, method)
    if option.nil?
      ''
    elsif method.is_a? Proc
      method.call(option)
    else
      option.public_send(method)
    end
  end

  def option_label_value(option)
    collection_methods.map do |method|
      extract_from_option option, method
    end
  end

  def prompt?
    options[:prompt] && selected_option_label.blank?
  end

  def include_blank?
    options[:include_blank] != false && options[:prompt].nil?
  end

  def include_blank_as_string
    if options[:include_blank] == true || options[:include_blank].nil?
      ''
    else
      options[:include_blank]
    end
  end

  def prompt_as_string
    if options[:prompt] == true
      I18n.translate('helpers.select.prompt', default: 'Please select')
    else
      options[:prompt]
    end
  end
end
