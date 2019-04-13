class AppMigration < ActiveRecord::Base
  belongs_to :app

  validates :app, :version, presence: true
  validates :version, uniqueness: true
end
