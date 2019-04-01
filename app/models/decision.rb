class Decision
  include ActiveModel::Model

  attr_accessor :split, :variant

  validates :split, :variant, presence: true

  def save!
    raise "Variant must be present in the split" unless split.has_variant?(variant)
    build_split_creation.save!.tap do
      split.reload
    end
  end

  private

  def build_split_creation
    split.build_split_creation(
      weighting_registry: { variant => 100 },
      decided_at: Time.zone.now
    )
  end
end
