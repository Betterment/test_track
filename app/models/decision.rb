class Decision
  include ActiveModel::Model

  attr_accessor :split, :variant, :takeaways

  validates :split, :variant, presence: true

  def save!
    raise "Variant must be present in the split" unless split.has_variant?(variant)

    split.with_lock do
      save_takeaways! if instance_variable_defined?(:@takeaways)
      split.reconfigure!(
        weighting_registry: { variant => 100 },
        decided_at: Time.zone.now,
      )
    end
  end

  private

  def save_takeaways!
    split.build_experiment_detail unless split.experiment_detail
    split.experiment_detail.takeaways = @takeaways
    split.experiment_detail.save!
  end
end
