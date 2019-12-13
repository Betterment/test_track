json.splits do
  @split_registry_snapshot.splits.each do |split|
    json.set! split.name do
      json.weights split.registry
      json.feature_gate split.feature_gate?
    end
  end
  json.merge!({})
end
json.(@split_registry_snapshot, :experience_sampling_weight)
