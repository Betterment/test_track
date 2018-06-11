json.splits do
  @split_registry.splits.each do |split|
    json.set! split.name do
      json.weights split.registry
      json.feature_gate split.feature_gate?
    end
  end
  json.merge!({})
end
json.(@split_registry, :experience_sampling_weight)
