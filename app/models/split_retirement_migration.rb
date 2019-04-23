class SplitRetirementMigration
  include ActiveModel::Validations

  attr_reader :app,
    :split,
    :decision

  validate :split_must_exist
  validate :decision_must_exist

  def initialize(params)
    @app = params[:app] || raise("Must provide app")
    @split = params[:split]
    @decision = params[:decision]
  end

  def save
    if valid?
      t = Time.zone.now
      split_model.reconfigure!(
        weighting_registry: { decision => 100 },
        decided_at: t,
        finished_at: t
      )
      true
    else
      false
    end
  end

  private

  def split_model
    @split_model ||= Split.find_by(owner_app: app, name: split)
  end

  def split_must_exist
    errors.add(:split, "must exist and belong to app") unless split_model
  end

  def decision_must_exist
    errors.add(:decision, "must exist in split") unless split_model&.has_variant?(decision)
  end
end
