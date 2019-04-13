class AppFeatureCompletionMigration
  include ActiveModel::Validations

  attr_reader :app, :feature_gate, :version_before_type_cast

  validate :feature_gate_must_exist

  delegate :version, to: :app_feature_completion

  def initialize(params)
    @app = params[:app] || raise("Must provide app")
    @feature_gate = params[:feature_gate]
    app_feature_completion.version = @version_before_type_cast = params[:version]
  end

  def valid?
    if destroy?
      super
    else
      app_feature_completion.valid?
    end
  end

  def errors
    if destroy?
      super
    else
      app_feature_completion.errors
    end
  end

  def save
    if destroy?
      valid? && app_feature_completion.destroy.destroyed?
    else
      app_feature_completion.save
    end
  end

  def destroy?
    version_before_type_cast.blank?
  end

  private

  def app_feature_completion
    @app_feature_completion ||= app.feature_completions.find_or_initialize_by(feature_gate: feature_gate_model)
  end

  def feature_gate_model
    Split.find_by(name: feature_gate)
  end

  def feature_gate_must_exist
    errors.add(:feature_gate, "must exist") unless feature_gate_model
  end
end
