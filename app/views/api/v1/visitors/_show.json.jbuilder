json.(visitor, :id)
json.assignments visitor.assignments.includes(:split).order(:updated_at), :split_name, :variant, :context, :unsynced
