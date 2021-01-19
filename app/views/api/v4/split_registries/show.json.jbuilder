json.splits @split_registry.splits do |split|
  json.name split.name

  json.variants split.registry do |(variant_name, weight)|
    json.name variant_name
    json.weight weight
  end

  json.feature_gate split.feature_gate?
end

json.(@split_registry, :experience_sampling_weight)
