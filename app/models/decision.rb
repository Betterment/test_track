class Decision
  include ActiveModel::Model

  attr_accessor :variant, :split

  validates :variant, presence: true, allow_blank: false
  validates :split, presence: true

  validate :variant_belongs_to_split

  def save!
    raise errors.full_messages.to_sentence unless valid?

    split.decide!(variant)

    true
  end

  private

  def variant_belongs_to_split
    errors.add(:variant, "#{variant} is not a valid variant for split") unless split.has_variant? variant
  end
end
