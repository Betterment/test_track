class DeterministicAssignmentCreation
  attr_reader :visitor_id, :split_name, :bulk_assignment_id, :mixpanel_result, :context

  def initialize(params)
    @visitor_id = params[:visitor_id]
    @split_name = params[:split_name]
    @mixpanel_result = params[:mixpanel_result]
    @context = params[:context]
    raise "Deterministic assignments must not specify a variant." if params[:variant]
  end

  def self.create!(params)
    new(params).tap(&:save!)
  end

  def save!
    if should_create_or_update_assignment?
      ArbitraryAssignmentCreation.create!(
        visitor_id: visitor_id,
        split_name: split_name,
        variant: variant_calculator.variant,
        mixpanel_result: mixpanel_result,
        context: context,
        updated_at: updated_at
      )
    end
  end

  def variant_calculator
    @variant_calculator ||= VariantCalculator.new(visitor_id: visitor_id, split: split)
  end

  def split
    @split ||= Split.find_by!(name: split_name)
  end

  def existing_assignment
    Assignment.find_by visitor: visitor, split: split
  end

  def visitor
    @visitor ||= Visitor.from_id(visitor_id)
  end

  private

  def should_create_or_update_assignment?
    !split.feature_gate? && (!existing_assignment || existing_assignment.mixpanel_result != @mixpanel_result)
  end

  def updated_at
    existing_assignment && existing_assignment.updated_at
  end
end
