class PreviousSplitRegistry < ActiveRecord::Base
  belongs_to :split
  validates :registry, :superseded_at, presence: true
end
