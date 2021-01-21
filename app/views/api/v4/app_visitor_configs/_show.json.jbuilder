json.splits active_splits do |split|
  json.name split.name

  json.variants split.registry do |(variant_name, weight)|
    json.name variant_name
    json.weight weight
  end

  json.feature_gate split.feature_gate?
end

json.visitor do
  json.id visitor_id
  json.assignments assignments, :split_name, :variant
end

json.experience_sampling_weight experience_sampling_weight
