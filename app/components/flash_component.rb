# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  attr_reader :flash

  def initialize(flash:)
    super
    @flash = flash
  end

  def render?
    !flash.empty?
  end

  private

  def banner_args(type)
    {
      dismissible: true,
      mt: 5,
      scheme: scheme_types.fetch(type, type)
    }
  end

  def flash_types
    %i(error success warning)
  end

  def scheme_types
    {
      error: :danger,
    }
  end
end
