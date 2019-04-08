class ArbitraryAssignmentCreation
  attr_reader :visitor_id, :split_name, :variant, :bulk_assignment_id, :context

  def initialize(params = {})
    @visitor_id = params[:visitor_id]
    @split_name = params[:split_name]
    @variant = params[:variant]
    @mixpanel_result = params[:mixpanel_result]
    @bulk_assignment_id = params[:bulk_assignment_id]
    @context = params[:context]
    @force = params[:force] if params.key?(:force)
  end

  def save!
    if superseding?
      supersede!
    else
      save_new_assignment!
    end
  end

  def self.create!(params)
    new(params).tap(&:save!)
  end

  def force
    instance_variable_defined?(:@force) ? @force : false
  end

  private

  def save_new_assignment!
    assignment.assign_attributes(assignment_attrs)
    assignment.save!
  rescue ActiveRecord::RecordNotUnique
    @assignment = nil
    save!
  end

  def supersede!(now = Time.zone.now)
    assignment.with_lock do
      assignment.create_previous_assignment!(now)
      assignment.update! supersede_attrs(now)
    end
  end

  def visitor
    @visitor ||= Visitor.from_id(visitor_id)
  end

  def split
    @split ||= Split.find_by! name: split_name
  end

  def assignment
    @assignment ||= Assignment.find_or_initialize_by visitor: visitor, split: split
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
      variant: variant,
      mixpanel_result: mixpanel_result,
      bulk_assignment_id: bulk_assignment_id_for_save,
      context: context_for_save,
      force: force
    }
  end

  def supersede_attrs(updated_at)
    assignment_attrs.merge(
      individually_overridden: individual_override?,
      updated_at: updated_at,
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
end
