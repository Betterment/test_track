class AppFeatureCompletion < ActiveRecord::Base
  belongs_to :app
  belongs_to :feature_gate, class_name: "Split"

  attribute :version, :app_version

  validates :app, :version, presence: true
  validates :feature_gate, uniqueness: { scope: :app }
  validate :feature_gate_must_be_a_feature_gate

  scope :satisfied_by, ->(app_build) do
    where(
      arel_table[:app_id].eq(app_build.app_id)
      .and(arel_table[:version].lteq(app_build.version))
    )
  end

  scope :by_app_and_version, -> { joins(:app).merge(App.by_name).order(version: :desc) }

  private

  def feature_gate_must_be_a_feature_gate
    return if feature_gate.nil?

    errors.add(:feature_gate, "must be a feature gate") unless feature_gate.feature_gate?
  end
end
