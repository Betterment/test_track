json.splits active_splits do |split|
  json.name split.name
  json.weights split.registry
  json.feature_gate split.feature_gate?
end

json.visitor do
  json.id visitor_id
  json.assignments assignments, :split_name, :variant
end
