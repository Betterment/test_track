class StringInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    super(wrapper_options.merge(value:))
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
