class AppMigration < ActiveRecord::Base
  belongs_to :app

  validates :version, presence: true
  validates :version, uniqueness: { scope: :app }
end
