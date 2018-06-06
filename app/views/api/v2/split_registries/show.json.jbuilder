json.splits do
  @split_registry.splits.each do |split|
    json.set! split.name, split.registry
  end
  json.merge!({})
end
json.(@split_registry, :experience_sampling_weight)
