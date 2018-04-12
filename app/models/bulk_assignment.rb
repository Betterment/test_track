class BulkAssignment < ActiveRecord::Base
  has_many :assignments, dependent: :nullify
  has_many :previous_assignments, dependent: :nullify
  belongs_to :admin
  belongs_to :split
end
