class IdentifierClaim
  include ActiveModel::Model

  attr_accessor :identifier_type, :visitor_id, :value

  attr_reader :identifier

  validates :identifier_type, :visitor_id, :value, presence: true
  validate :identifier_type_must_exist

  def visitor
    @visitor ||= Visitor.from_id(visitor_id) if visitor_id
  end

  def save!
    return false unless valid?

    find_or_create_identifier
    supersede_visitor! if identifier.visitor != visitor
    true
  end

  def self.create!(params)
    new(params).tap(&:save!)
  end

  private

  def supersede_visitor!
    VisitorSupersessionCreation.new(superseded_visitor: visitor, superseding_visitor: identifier.visitor).save!
  end

  def find_or_create_identifier
    @identifier = find_identifier || create_identifier
  end

  def find_identifier
    Identifier.find_by(identifier_type: actual_identifier_type, value: value)
  end

  def create_identifier
    Identifier.create!(visitor: non_conflicting_visitor, identifier_type: actual_identifier_type, value: value)
  rescue ActiveRecord::RecordNotUnique
    Identifier.find_by!(identifier_type: actual_identifier_type, value: value)
  end

  def non_conflicting_visitor
    @non_conflicting_visitor ||= _non_conflicting_visitor
  end

  def _non_conflicting_visitor
    if visitor.identifiers.where(identifier_type: actual_identifier_type).where.not(value: value).present?
      Visitor.create!
    else
      visitor
    end
  end

  def actual_identifier_type
    @actual_identifier_type ||= IdentifierType.find_by(name: identifier_type)
  end

  def identifier_type_must_exist
    errors.add(:identifier_type, "does not exist") unless actual_identifier_type
  end
end
