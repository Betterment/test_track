class RadioButtonInput < SimpleForm::Inputs::Base
  include RadioButton

  def input(_wrapper_options)
    build_radio_button(options)
  end
end
