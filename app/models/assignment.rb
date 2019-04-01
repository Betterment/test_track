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

  scope :unsynced_to_mixpanel, -> { where("mixpanel_result = 'failure' OR mixpanel_result IS NULL") }

  normalize_attributes :mixpanel_result

  delegate :name, to: :split, prefix: true

  class << self
    def to_hash
      Hash[all.includes(:split).map { |a| [a.split.name.to_sym, a.variant.to_sym] }]
    end

    def for_presentation(app_build: nil)
      q =
        if app_build.present?
          for_app_build(app_build)
        else
          where("splits.finished_at is null")
        end
      q.joins(:split)
        .where("splits.decided_at is null or assignments.updated_at > splits.decided_at")
    end

    private

    def for_app_build(app_build)
      where("splits.finished_at is null or splits.finished_at > ?", app_build.built_at)
        .where(<<~SQL, app_build.app_id, app_build.version.to_pg_array)
          splits.feature_gate = false
          or exists (
            select 1 from feature_completions fc
            where fc.app_id = ?
              and fc.split_id = assignments.split_id
              and fc.version <= ?
          )
        SQL
    end
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
