class Identifier < ActiveRecord::Base
  belongs_to :visitor, required: true
  belongs_to :identifier_type, required: true
  validates :value, presence: true
end
