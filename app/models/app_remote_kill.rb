class AppRemoteKill < ActiveRecord::Base
  belongs_to :app
  belongs_to :split

  attribute :first_bad_version, :app_version
  attribute :fixed_version, :app_version

  validates :app, :split, :reason, :override_to, :first_bad_version, presence: true
  validates :reason, uniqueness: { scope: %i(app split) }

  validate :override_to_must_exist
  validate :fixed_version_must_be_greater_than_first_bad_version
  validate :must_not_overlap_existing

  # This scope requires you to BYO `splits` FROM clause either via join or an
  # outer scope, if using this as a subselect.
  scope :affecting, ->(app_build) do
    where(
      arel_table[:split_id].eq(Split.arel_table[:id])
      .and(arel_table[:app_id].eq(app_build.app_id))
      .and(arel_table[:first_bad_version].lteq(app_build.version))
      .and(
        Arel::Nodes::Or.new(
          arel_table[:fixed_version].eq(nil),
          arel_table[:fixed_version].gt(app_build.version)
        )
      )
    )
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
        .and(
          Arel::Nodes::Grouping.new(
            Arel::Nodes::Or.new(
              arel_table[:fixed_version].eq(nil),
              arel_table[:fixed_version].gt(other.first_bad_version)
            )
          )
        )
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
