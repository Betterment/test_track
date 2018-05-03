class BulkReassignment
  include ActiveModel::Model

  attr_accessor :assignments, :bulk_assignment

  validates :bulk_assignment, presence: true

  def save
    return false unless valid?
    with_transactional_lock('bulk_reassignment') do
      insert_previous_assignments
      update_assignments
    end
    true
  end

  def save!
    save || raise(errors.full_messages.to_sentence)
  end

  def self.create!(*args)
    new(*args).tap(&:save!)
  end

  private

  delegate :connection, :with_transactional_lock, to: BulkAssignment

  def insert_previous_assignments
    connection.execute(<<-SQL)
      INSERT INTO previous_assignments (
        variant,
        assignment_id,
        superseded_at,
        created_at,
        updated_at,
        bulk_assignment_id,
        individually_overridden,
        visitor_supersession_id,
        context
      )
      SELECT
        a.variant,
        a.id,
        #{connection.quote(now)},
        a.updated_at,
        #{connection.quote(now)},
        a.bulk_assignment_id,
        a.individually_overridden,
        visitor_supersession_id,
        context
      FROM assignments a
      WHERE a.id #{assignment_id_clause}
    SQL
  end

  def update_assignments
    connection.execute(<<-SQL)
      UPDATE assignments SET
        variant = #{connection.quote(bulk_assignment.variant)},
        updated_at = #{connection.quote(now)},
        mixpanel_result = NULL,
        bulk_assignment_id = #{connection.quote(bulk_assignment)},
        visitor_supersession_id = NULL,
        context = 'bulk_assignment'
      WHERE id #{assignment_id_clause}
    SQL
  end

  def assignment_id_clause
    if assignments.is_a?(ActiveRecord::Relation)
      "IN (#{assignment_ids_sql})"
    elsif assignments.present?
      "IN (#{assignments.map { |a| connection.quote(a.is_a?(Assignment) ? a.id : a) }.join(',')})"
    else
      "IS NULL"
    end
  end

  def assignment_ids_sql
    assignments.select(:id).lock.to_sql
  end

  def now
    bulk_assignment.created_at
  end
end
