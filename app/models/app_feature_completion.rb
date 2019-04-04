class AppFeatureCompletion < ActiveRecord::Base
  belongs_to :app
  belongs_to :split

  attribute :version, :app_version

  validates :app, :split, :version, presence: true
  validates :split, uniqueness: { scope: :app }

  # This scope requires you to BYO `splits` FROM clause
  scope :satisfied_by, ->(app_build) do
    where('split_id = splits.id')
      .where(<<~SQL, app_id: app_build.app_id, version: app_build.version.to_pg_array)
        app_id = :app_id and app_feature_completions.version <= :version
      SQL
  end
end
