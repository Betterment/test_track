class AppFeatureCompletion < ActiveRecord::Base
  belongs_to :app
  belongs_to :split

  attribute :version, :app_version

  validates :app, :split, :version, presence: true
  validates :split, uniqueness: { scope: :app }
end
