class FeatureCompletion < ActiveRecord::Base
  belongs_to :split
  belongs_to :app

  validates :split_id, uniqueness: { scope: :app_id }

  attribute :version, :app_version
end
