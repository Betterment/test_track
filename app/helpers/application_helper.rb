module ApplicationHelper
  def identifier_types
    IdentifierType.all.reverse
  end

  def percentage(ratio)
    "#{(ratio * 100).round}%"
  end
end
