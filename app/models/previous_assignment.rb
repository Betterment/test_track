class PreviousAssignment < ActiveRecord::Base
  belongs_to :assignment, required: true
  belongs_to :bulk_assignment, required: false
  belongs_to :visitor_supersession, required: false

  validates :variant, :superseded_at, presence: true
end
