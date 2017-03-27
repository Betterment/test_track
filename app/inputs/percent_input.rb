class PercentInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options[:type] = 'number'
    merged_input_options[:value] = value

    @builder.text_field(attribute_name, merged_input_options)
  end

  def symbol(_wrapper_options)
    '%'
  end

  private

  def value
    value = object.public_send(@attribute_name) if object
    if value.nil?
      options[:default]
    else
      value
    end
  end
end
