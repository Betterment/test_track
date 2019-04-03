class Decision
  include ActiveModel::Model

  attr_accessor :split, :variant

  validates :split, :variant, presence: true

  def save!
    raise "Variant must be present in the split" unless split.has_variant?(variant)

    split.reconfigure!(
      weighting_registry: { variant => 100 },
      decided_at: Time.zone.now
    )
  end
end
