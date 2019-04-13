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
    if version_before_type_cast
      app_feature_completion.valid?
    else
      super
    end
  end

  def errors
    if version_before_type_cast
      app_feature_completion.errors
    else
      super
    end
  end

  def save
    if version_before_type_cast
      app_feature_completion.save
    else
      if valid? && app_feature_completion.persisted?
        app_feature_completion.destroy.destroyed?
      else
        false
      end
    end
  end

  def app_feature_completion
    @app_feature_completion ||= app.feature_completions.find_or_initialize_by(feature_gate: feature_gate_model)
  end

  def feature_gate_model
    Split.find_by(name: feature_gate)
  end

  private

  def feature_gate_must_exist
    errors.add(:feature_gate, "must exist") unless feature_gate_model
  end
end
