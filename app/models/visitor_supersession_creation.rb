class VisitorSupersessionCreation
  include ActiveModel::Model

  attr_accessor :superseded_visitor, :superseding_visitor

  validates :superseded_visitor, :superseding_visitor, presence: true

  def save!
    save || raise(ActiveRecord::RecordInvalid, self)
  end

  def save
    return false unless valid?

    # we don't want to supersede a visitor that is associated with an identifier
    # because that could result in strange behavior, so if that somehow comes up
    # we just no-op and quitely don't do anything
    unless superseded_visitor.identifiers.exists?
      VisitorSupersession.create!(superseded_visitor: superseded_visitor, superseding_visitor: superseding_visitor)
    end

    true
  end
end
