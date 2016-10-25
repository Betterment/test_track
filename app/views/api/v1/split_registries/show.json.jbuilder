@active_splits.each do |split|
  json.set! split.name, split.registry
end
