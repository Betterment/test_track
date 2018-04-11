class VisitorLookup
  include ActiveModel::Model

  attr_accessor :identifier_type_name, :identifier_value

  def visitor
    @visitor ||= identifier.visitor
  end

  private

  def identifier_type
    @identifier_type ||= IdentifierType.find_by! name: identifier_type_name
  end

  def identifier
    @identifier ||= _identifier
  end

  def _identifier
    Identifier.create_with(visitor: Visitor.new).find_or_create_by!(
      identifier_type: identifier_type,
      value: identifier_value
    )
  rescue ActiveRecord::RecordNotUnique
    Identifier.find_by!(identifier_type: identifier_type, value: identifier_value)
  end
end
