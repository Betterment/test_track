json.(visitor, :id)
json.assignments visitor.assignments.includes(:split), :split_name, :variant, :context, :unsynced
