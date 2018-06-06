class GroupedCollectionSelectInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  include ActionView::Helpers::OutputSafetyHelper

  def display_dropdown(_wrapper_options)
    safe_join build_dropdown
  end

  def selected(_wrapper_options)
    selected_option ? option_label(selected_option) : options[:include_blank]
  end

  private

  def selected_option
    current_value = object.public_send(attribute_name)
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @_selected ||= collections.find { |option| option_value(option) == current_value || option == current_value }
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def collections
    grouped_collection.flat_map { |collection| collection.try(:send, group_method) }
  end

  def build_dropdown
    dropdown = grouped_collection.map do |parent|
      @builder.template.content_tag(:div, class: 'group') { group_header(parent) + group_dropdown(parent) }
    end
    dropdown.unshift(blank_option) if options[:include_blank]
    dropdown
  end

  def blank_option
    css_classes = %w(selectable)
    css_classes << 'selected' if selected_option.nil?
    @builder.template.content_tag(:div, class: 'group') do
      @builder.template.content_tag(:ul) do
        @builder.template.content_tag(:li, options[:include_blank], class: css_classes.join(' '), data: { value: '' })
      end
    end
  end

  def group_header(parent)
    @builder.template.content_tag(:h5, extract_from_option(parent, group_label_method))
  end

  def group_dropdown(parent)
    group = parent.send(group_method) || []
    dropdown = group.map do |option|
      css_classes = %w(selectable)
      css_classes << 'selected' if selected_option == option
      @builder.template.content_tag(:li, option_label(option), class: css_classes.join(' '), data: { value: option_value(option) })
    end
    @builder.template.content_tag(:ul) { safe_join dropdown }
  end

  def label_method
    @_label_method ||= collection_methods.first # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def value_method
    @_value_method ||= collection_methods.last # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def collection_methods
    @_collection_methods ||= detect_collection_methods # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def option_label(option)
    @builder.template.content_tag(:span, extract_from_option(option, label_method))
  end

  def option_value(option)
    extract_from_option(option, value_method)
  end

  def group_label_method
    @_group_label_method ||= options.delete(:group_label_method)

    unless @_group_label_method
      common_method_for = detect_common_display_methods(detect_collection_classes(grouped_collection))
      @_group_label_method = common_method_for[:label]
    end

    @_group_label_method
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
end
