class BulkAssignmentJob < ApplicationJob
  def perform(bulk_assignment_params)
    BulkAssignmentCreation.new(bulk_assignment_params).save!
  end
end
