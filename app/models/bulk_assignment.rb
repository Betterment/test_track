class BulkAssignment < ActiveRecord::Base
  has_many :assignments
  has_many :previous_assignments
  belongs_to :admin
  belongs_to :split
end
