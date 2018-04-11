class BulkAssignmentCreation
  include ActiveModel::Model

  attr_accessor :identifiers_listing, :identifier_type_id, :variant, :reason, :split, :admin
  attr_reader :force_identifier_creation
  alias force_identifier_creation? force_identifier_creation

  validates :identifiers_listing, presence: true, allow_blank: false
  validates :identifier_type_id, presence: true, allow_blank: false
  validates :variant, presence: true, allow_blank: false
  validates :reason, presence: true, allow_blank: false, length: { minimum: 5, message: "must provide a valid reason for bulk assignment" }

  validate :most_identifiers_must_exist

  NEW_IDENTIFIER_CREATION_RATIO_WARNING_THRESHOLD = 0.02

  def save
    return false unless valid?

    Assignment.transaction do
      bulk_assignment.save!
      BulkReassignment.create!(assignments: existing_assignments, bulk_assignment: bulk_assignment)
      assignment_creations.each(&:save!)
    end
    true
  end

  def save!
    save || raise(ActiveRecord::RecordInvalid, self)
  end

  def self.create(params)
    new(params).tap(&:save)
  end

  def bulk_assignment
    @bulk_assignment ||= admin.bulk_assignments.build(reason: reason, split: split, variant: variant)
  end

  def new_identifier_creation_ratio
    return 0 unless total_identifiers_to_assign_count.positive?
    @new_identifier_creation_ratio ||= 1 - (existing_identifiers_count.to_f / total_identifiers_to_assign_count)
  end

  def new_identifier_creation_ratio_above_warning_threshold?
    return false unless identifier_type
    new_identifier_creation_ratio > NEW_IDENTIFIER_CREATION_RATIO_WARNING_THRESHOLD
  end

  def new_identifier_count
    total_identifiers_to_assign_count - existing_identifiers_count
  end

  def total_identifiers_to_assign_count
    ids_to_assign.blank? ? 0 : ids_to_assign.size
  end

  def force_identifier_creation=(value)
    @force_identifier_creation = ActiveRecord::Type::Boolean.new.cast(value)
  end

  private

  attr_reader :identifiers_fetched
  alias identifiers_fetched? identifiers_fetched

  def assignment_creations
    @assignment_creations ||= unassigned_identifiers.map do |identifier|
      ArbitraryAssignmentCreation.new(
        visitor_id: identifier.visitor_id,
        split_name: split.name,
        variant: variant,
        bulk_assignment_id: bulk_assignment.id
      )
    end
  end

  def identifier_type
    @identifier_type ||= IdentifierType.find_by(id: identifier_type_id)
  end

  def existing_assignments
    ensure_identifiers
    Assignment.where(visitor_id: existing_visitor_ids, split: split).where.not(variant: variant)
  end

  def unassigned_identifiers
    ensure_identifiers
    Identifier.where(id: identifier_ids).where(<<-SQL)
      NOT EXISTS (
        SELECT 1
        FROM assignments
        WHERE visitor_id = identifiers.visitor_id
        AND split_id = #{Identifier.connection.quote(split.id)}
      )
    SQL
  end

  def ensure_identifiers
    return false if identifiers_fetched?
    @identifiers_fetched = true
    ids_to_assign.each do |i|
      identifier = Identifier.find_or_initialize_by(identifier_type_id: identifier_type_id, value: i)
      identifier.persisted? ? record_existing_visitor!(identifier) : persist_new_identifier!(identifier)
      identifier_ids << identifier.id
    end
    true
  end

  def record_existing_visitor!(identifier)
    existing_visitor_ids << identifier.visitor_id
  end

  def persist_new_identifier!(identifier)
    identifier.visitor = Visitor.create!
    identifier.save!
  end

  def existing_visitor_ids
    raise "must ensure_identifiers first" unless identifiers_fetched?
    @existing_visitor_ids ||= []
  end

  def identifier_ids
    raise "must ensure_identifiers first" unless identifiers_fetched?
    @identifier_ids ||= []
  end

  def ids_to_assign
    @ids_to_assign ||= identifiers_listing.strip.gsub(/[\s,]+/, ',').split(',').map(&:strip) if identifiers_listing.present?
  end

  def existing_identifiers_count
    Identifier.where(identifier_type: identifier_type).where("value IN (?)", ids_to_assign).count
  end

  def most_identifiers_must_exist
    return if force_identifier_creation? || !new_identifier_creation_ratio_above_warning_threshold?
    errors.add(:identifiers_listing, "would create #{new_identifier_count} previously unknown identifiers")
  end
end
