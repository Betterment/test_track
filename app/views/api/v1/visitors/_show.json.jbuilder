json.(visitor, :id)
json.assignments visitor.assignments.includes(:split).order(:created_at), :split_name, :variant, :context, :unsynced
