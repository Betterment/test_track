class BatchArbitraryAssignmentCreation
  attr_reader :visitor_id, :assignments, :force

  def initialize(
    visitor_id:,
    assignments:,
    force: false
  )
    @visitor_id = visitor_id
    @assignments = assignments
    @force = force
  end

  def save!
    ActiveRecord::Base.transaction do
      assignments.each do |assignment|
        ArbitraryAssignmentCreation.create!(
          assignment.merge(visitor_id: visitor_id, force: force, mixpanel_result: 'success')
        )
      end
    end
  end

  def self.create!(params)
    new(params.to_h.symbolize_keys).tap(&:save!)
  end
end
