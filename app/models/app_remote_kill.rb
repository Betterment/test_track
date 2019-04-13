class AppRemoteKill < ActiveRecord::Base
  belongs_to :app
  belongs_to :split

  attribute :first_bad_version, :app_version
  attribute :fixed_version, :app_version

  validates :app, :split, :reason, :override_to, :first_bad_version, presence: true
  validates :reason,
    uniqueness: { scope: %i(app split) },
    format: { with: /\A[a-z\d_]*\z/, message: "must be alphanumeric snake_case" }

  validate :override_to_must_exist
  validate :fixed_version_must_be_greater_than_first_bad_version
  validate :must_not_overlap_existing

  scope :affecting, ->(app_build, override: false, overridden_at: nil) do
    where(
      arel_table[:app_id].eq(app_build.app_id)
      .and(arel_table[:first_bad_version].lteq(app_build.version))
      .and(arel_fixed_version_is_null_or_greater_than(app_build.version))
      .and(
        Arel::Nodes::Grouping.new(
          arel_is_false(override)
          .or(arel_table[:updated_at].gt(overridden_at))
        )
      )
    )
  end

  class << self
    private

    def arel_is_false(value_or_arel)
      Arel::Nodes::Grouping.new(Arel::Nodes::False.new).eq(value_or_arel)
    end
  end

  scope :overlapping, ->(other) do
    where(app_id: other.app_id, split_id: other.split_id)
      .where.not(id: other.id)
      .where(
        if other.fixed_version.nil?
          Arel::Nodes::True.new
        else
          arel_table[:first_bad_version].lt(other.fixed_version)
        end
        .and(arel_fixed_version_is_null_or_greater_than(other.first_bad_version))
      )
  end

  def self.arel_fixed_version_is_null_or_greater_than(version)
    Arel::Nodes::Grouping.new(
      arel_table[:fixed_version].eq(nil)
      .or(arel_table[:fixed_version].gt(version))
    )
  end

  def override_to_must_exist
    return unless split

    errors.add(:override_to, "must exist in split's current variants") unless split.has_variant?(override_to)
  end

  def fixed_version_must_be_greater_than_first_bad_version
    return if fixed_version.nil?

    errors.add(:fixed_version, "must be greater than first bad version") unless fixed_version > first_bad_version
  end

  def must_not_overlap_existing
    return if first_bad_version.nil? || split.nil? || app.nil?

    overlapping = self.class.overlapping(self)
    return if overlapping.empty?

    errors.add(:base, "must not overlap existing app remote kills: #{overlapping.map(&:reason).join(', ')}")
  end
end
