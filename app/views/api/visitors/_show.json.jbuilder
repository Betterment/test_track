json.(visitor,
  :id,
  :assignment_registry)
json.unsynced_splits visitor.unsynced_splits.map(&:name)
