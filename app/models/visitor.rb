class Visitor < ActiveRecord::Base
  UUID_REGEX = /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/i

  has_many :assignments, dependent: :nullify
  has_many :unsynced_assignments, -> { unsynced_to_mixpanel }, class_name: "Assignment", inverse_of: :visitor
  has_many :unsynced_splits, through: :unsynced_assignments, source: :split
  has_many :identifiers, dependent: :nullify

  validates :id, format: UUID_REGEX, allow_nil: true

  def assignment_registry
    assignments.to_hash
  end

  def self.from_id(visitor_id)
    Visitor.find_or_create_by! id: visitor_id
  rescue ActiveRecord::RecordNotUnique
    Visitor.find_by! id: visitor_id
  end
end
