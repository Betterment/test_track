class ArbitraryAssignmentCreation
  attr_reader :visitor_id, :split_name, :variant, :bulk_assignment_id, :context, :force

  def initialize(
    visitor_id: nil,
    split_name: nil,
    variant: nil,
    mixpanel_result: nil,
    bulk_assignment_id: nil,
    context: nil,
    force: false
  )
    @visitor_id = visitor_id
    @split_name = split_name
    @variant = variant
    @mixpanel_result = mixpanel_result
    @bulk_assignment_id = bulk_assignment_id
    @context = context
    @force = force
  end

  def save!
    if superseding?
      supersede!
    else
      save_new_assignment!
    end
  end

  def self.create!(params)
    new(**params.to_h.symbolize_keys).tap(&:save!)
  end

  private

  def save_new_assignment!
    assignment.assign_attributes(assignment_attrs)
    assignment.save!
  rescue ActiveRecord::RecordNotUnique
    @assignment = nil
    save!
  end

  def supersede!
    assignment.with_lock do
      assignment.create_previous_assignment!(now)
      assignment.update! supersede_attrs
    end
  end

  def visitor
    @visitor ||= Visitor.from_id(visitor_id)
  end

  def split
    @split ||= Split.find_by! name: split_name
  end

  def assignment
    @assignment ||= Assignment.find_or_initialize_by visitor:, split:
  end

  def changed_variant?
    assignment.variant != variant
  end

  def mixpanel_result
    @mixpanel_result ||= assignment.mixpanel_result
  end

  def superseding?
    assignment.persisted? && changed_variant?
  end

  def individual_override?
    superseding? && (assignment.individually_overridden || !bulk_assignment?)
  end

  def bulk_assignment?
    bulk_assignment_id.present?
  end

  def bulk_assignment_id_for_supersession
    !bulk_assignment? && individual_override? ? nil : bulk_assignment_id_for_save
  end

  def assignment_attrs
    {
      variant:,
      mixpanel_result:,
      bulk_assignment_id: bulk_assignment_id_for_save,
      context: context_for_save,
      updated_at: now,
      force:
    }
  end

  def supersede_attrs
    assignment_attrs.merge(
      individually_overridden: individual_override?,
      bulk_assignment_id: bulk_assignment_id_for_supersession,
      context: context_for_supersession
    )
  end

  def bulk_assignment_id_for_save
    assignment.bulk_assignment_id || bulk_assignment_id
  end

  def context_for_save
    if bulk_assignment?
      'bulk_assignment'
    else
      assignment.context || context
    end
  end

  def context_for_supersession
    if individual_override?
      'individually_overridden'
    else
      context_for_save
    end
  end

  def now
    @now ||= Time.zone.now
  end
end
