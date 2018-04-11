class VisitorSupersession < ActiveRecord::Base
  belongs_to :superseded_visitor, class_name: "Visitor", inverse_of: false
  belongs_to :superseding_visitor, class_name: "Visitor", inverse_of: false

  after_create :merge_assignments!

  private

  def merge_assignments!
    target_split_ids = superseding_visitor.assignments.map(&:split_id).to_set
    superseded_visitor.assignments.order(:id).each do |a|
      create_or_ignore_duplicate(a) unless target_split_ids.include?(a.split_id)
    end
  end

  def create_or_ignore_duplicate(assignment)
    transaction(requires_new: true) do
      superseding_visitor.assignments.create!(
        variant: assignment.variant,
        split_id: assignment.split_id,
        context: 'visitor_supersession',
        visitor_supersession: self
      )
    end
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation # rubocop:disable Lint/HandleExceptions
    # the goal here is to make sure that any splits that the old visitor had
    # (that the new visitor doesn't have) are carried over to the new visitor.
    # so, if there is a conflict here, we can safely ignore it.
  end
end
