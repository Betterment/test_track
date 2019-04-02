class Assignment < ActiveRecord::Base
  include AttributeNormalizer

  belongs_to :visitor, required: true
  belongs_to :split, required: true
  belongs_to :bulk_assignment, required: false
  belongs_to :visitor_supersession, required: false

  has_many :previous_assignments, dependent: :nullify
  has_many :variant_details, through: :split

  validates :variant, presence: true
  validates :mixpanel_result, inclusion: { in: %w(success failure) }, allow_nil: true
  validate :variant_must_exist

  normalize_attributes :mixpanel_result

  delegate :name, to: :split, prefix: true

  scope :unsynced_to_mixpanel, -> { where("mixpanel_result = 'failure' OR mixpanel_result IS NULL") }

  scope :for_presentation, ->(app_build: nil) do
    q = excluding_decision_overrides
    app_build.present? ? q.for_app_build(app_build) : q.for_active_splits
  end

  scope :for_app_build, ->(app_build) do
    for_active_splits(as_of: app_build.built_at)
      .excluding_incomplete_features(app_id: app_build.app_id, version: app_build.version)
  end

  scope :excluding_decision_overrides, -> do
    joins(:split).where('splits.decided_at is null or assignments.updated_at > splits.decided_at')
  end

  scope :for_active_splits, ->(as_of: nil) do
    joins(:split).merge(Split.active(as_of: as_of))
  end

  scope :excluding_incomplete_features, ->(app_id:, version:) do
    joins(:split).where(<<~SQL, app_id, AppVersion.new(version).to_pg_array)
      splits.feature_gate = false
      or exists (
        select 1 from feature_completions fc
        where fc.app_id = ?
          and fc.split_id = assignments.split_id
          and fc.version <= ?
      )
    SQL
  end

  def variant_detail
    @variant_detail ||= begin
      detail = variant_details.select { |d| d.variant == variant }.first
      detail || VariantDetail.new(split: split, variant: variant)
    end
  end

  def create_previous_assignment!(now)
    previous_assignments.create!(previous_assignment_params.merge(updated_at: now, superseded_at: now))
  end

  def unsynced?
    mixpanel_result.nil? || mixpanel_result == 'failure'
  end
  alias unsynced unsynced?

  def self.to_hash
    Hash[all.includes(:split).map { |a| [a.split.name.to_sym, a.variant.to_sym] }]
  end

  private

  def previous_assignment_params
    {
      variant: variant,
      created_at: updated_at,
      bulk_assignment_id: bulk_assignment_id,
      individually_overridden: individually_overridden,
      visitor_supersession_id: visitor_supersession_id,
      context: context
    }
  end

  def variant_must_exist
    return unless split
    errors.add(:variant, "must be specified in split's current variations") unless split.has_variant?(variant)
  end
end
