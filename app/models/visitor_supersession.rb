class VisitorSupersession < ActiveRecord::Base
  belongs_to :superseded_visitor, class_name: "Visitor"
  belongs_to :superseding_visitor, class_name: "Visitor"

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
    # ignore or find
    # we're not using the result, so probably just ignore
  end
end
