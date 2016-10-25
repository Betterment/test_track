class VisitorSupersession < ActiveRecord::Base
  belongs_to :superseded_visitor, class_name: "Visitor"
  belongs_to :superseding_visitor, class_name: "Visitor"

  after_create :merge_assignments!

  private

  def merge_assignments! # rubocop:disable Metrics/AbcSize
    target_split_ids = superseding_visitor.assignments.map(&:split_id).to_set
    superseded_visitor.assignments.order(:id).map do |a|
      superseding_visitor.assignments.create!(
        variant: a.variant,
        split_id: a.split_id,
        context: 'visitor_supersession',
        visitor_supersession: self
      ) unless target_split_ids.include?(a.split_id)
    end
  end
end
