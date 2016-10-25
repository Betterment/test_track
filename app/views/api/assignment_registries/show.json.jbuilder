@assignments.each do |assignment|
  json.set! assignment.split.name, assignment.variant
end
