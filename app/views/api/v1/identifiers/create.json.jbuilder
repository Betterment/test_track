json.visitor do
  json.partial!('api/v1/visitors/show', visitor: @identifier.visitor)
end
