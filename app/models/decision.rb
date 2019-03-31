class Decision
  include ActiveModel::Model

  attr_accessor :split, :variant

  validates :split, :variant, presence: true

  def save!
    build_split_creation.save!.tap do
      split.reload
    end
  end

  private

  def assignment_variant
    split.has_variant?(variant) ? variant : split.variants.first
  end

  def build_split_creation
    split.build_split_creation(
      weighting_registry: { assignment_variant => 100 },
      decision: variant,
      decided_at: Time.zone.now
    )
  end
end
