json.visitor do
  json.partial!('api/visitors/show', visitor: @identifier.visitor)
end
