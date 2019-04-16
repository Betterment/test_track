class AppFeatureCompletion < ActiveRecord::Base
  belongs_to :app
  belongs_to :split

  attribute :version, :app_version

  validates :app, :split, :version, presence: true
  validates :split, uniqueness: { scope: :app }

  scope :satisfied_by, ->(app_build) do
    where(
      arel_table[:app_id].eq(app_build.app_id)
      .and(arel_table[:version].lteq(app_build.version))
    )
  end
end
