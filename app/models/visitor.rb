class Visitor < ActiveRecord::Base
  UUID_REGEX = /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/i.freeze

  has_many :assignments, -> { for_presentation }, dependent: :nullify, inverse_of: :visitor
  has_many :identifiers, dependent: :nullify

  validates :id, format: UUID_REGEX, allow_nil: true

  def assignments_for(app_build)
    Assignment.where(visitor: self).for_presentation(app_build: app_build)
  end

  def assignment_registry
    assignments.to_hash
  end

  def self.from_id(visitor_id)
    Visitor.find_or_create_by! id: visitor_id
  rescue ActiveRecord::RecordNotUnique
    Visitor.find(visitor_id)
  end
end
