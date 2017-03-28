class VariantDetail < ActiveRecord::Base
  belongs_to :split

  validate :variant_must_exist, on: :create
  validates :display_name, :description, presence: true

  def display_name
    super || variant
  end

  private

  def variant_must_exist
    errors.add(:base, "Variant does not exist: #{variant}") unless split.has_variant?(variant)
  end
end
