class CollectionRadioButtonsInput < SimpleForm::Inputs::CollectionSelectInput
  include ActionView::Helpers::OutputSafetyHelper
  include RadioButton

  def input(wrapper_options) # rubocop:disable Metrics/AbcSize
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.content_tag :ul, merged_input_options.merge(class: 'radio-options') do
      radio_options = collection.map do |option|
        label, value = option_label_value(option, collection_methods)

        radio_button_options = option.is_a?(Hash) ? option : {}
        radio_button_options[:value] = value
        radio_button_options[:label] = label
        radio_button_options[:description] = extract_from_option(option, description_method) if description_method
        radio_button_options[:state] = if state_method
                                         extract_from_option(option, state_method) || state(value)
                                       else
                                         state(value)
                                       end

        build_radio_button(radio_button_options)
      end
      radio_options << build_radio_button(value: '', label: blank_label, state: state('')) if options[:include_blank]
      safe_join radio_options
    end
  end

  private

  def state(value)
    if options.fetch(:selected, nil) == value || selected?(value)
      :selected
    else
      :unselected
    end
  end

  def blank_label
    if options[:include_blank].is_a? String
      options[:include_blank]
    else
      'None of the above'
    end
  end

  def collection_methods
    @collection_methods ||= detect_collection_methods
  end

  def description_method
    @description_method ||= options.delete(:description_method)
  end

  def state_method
    @state_method ||= options.delete(:state_method)
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

  def option_label_value(option, collection_methods)
    collection_methods.map do |method|
      extract_from_option option, method
    end
  end
end
