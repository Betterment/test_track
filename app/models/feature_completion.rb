class FeatureCompletion < ActiveRecord::Base
  belongs_to :split
  belongs_to :app

  validates :split, uniqueness: { scope: :app }
  validates :split, :app, :version, presence: true

  attribute :version, :app_version
end
