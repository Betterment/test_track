json.splits do
  active_splits.each do |split|
    json.set! split.name, split.registry
  end
end

json.visitor do
  json.id visitor_id
  json.assignments assignments, :split_name, :variant, :context, :unsynced
end
