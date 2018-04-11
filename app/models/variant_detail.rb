class VariantDetail < ActiveRecord::Base
  belongs_to :split

  has_attached_file :screenshot

  validate :variant_must_exist
  validates :display_name, :description, presence: true
  validates_with AttachmentSizeValidator, attributes: :screenshot, less_than: TestTrack::AttachmentSettings.max_size
  validates_with AttachmentContentTypeValidator, attributes: :screenshot, content_type: ['image/png', 'image/jpeg', 'image/gif']

  def display_name
    super || variant
  end

  def weight
    @weight ||= split.variant_weight(variant)
  end

  def assignment_count
    @assignment_count ||= split.assignment_count_for_variant(variant)
  end

  def retirable?
    weight.zero? && assignment_count.positive?
  end

  private

  def variant_must_exist
    errors.add(:base, "Variant does not exist: #{variant}") unless split.has_variant?(variant)
  end
end
