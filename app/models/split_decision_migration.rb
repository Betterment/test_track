class SplitDecisionMigration
  include ActiveModel::Validations

  attr_reader :app,
    :split,
    :variant

  validate :split_must_exist
  validate :variant_must_exist

  def initialize(params)
    @app = params[:app] || raise("Must provide app")
    @split = params[:split]
    @variant = params[:variant]
  end

  def save
    if valid?
      split_model.create_decision!(variant: variant)
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

  def variant_must_exist
    return unless split_model

    errors.add(:variant, "must exist in split") unless split_model.has_variant?(variant)
  end
end
