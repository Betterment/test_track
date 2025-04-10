class Admin::SplitAssignmentsController < AuthenticatedAdminController
  VIEW_LIMIT = 1000

  def index
    split = Split.find(params.require(:split_id))
    @split_name = split.name
    @assignments = split.assignments.includes(visitor: { identifiers: :identifier_type }).order(updated_at: :desc).limit(VIEW_LIMIT)
    flash.now[:warning] = "Only showing #{VIEW_LIMIT} of #{split.assignments.count} assignments" if split.assignments.count > VIEW_LIMIT
  end
end
