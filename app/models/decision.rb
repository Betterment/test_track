class Decision
  include ActiveModel::Model

  attr_accessor :variant, :split, :admin

  validates :variant, presence: true, allow_blank: false
  validates :split, presence: true
  validates :admin, presence: true

  validate :variant_belongs_to_split

  def save!
    raise errors.full_messages.to_sentence unless valid?

    weight_split_fully_to_variant
    reassign_existing_assignments

    true
  end

  def count
    raise "count unavailable for unsaved Decision" unless bulk_assignment
    bulk_assignment.assignments.count
  end

  private

  def weight_split_fully_to_variant
    split.reweight!(variant => 100)
  end

  def reassign_existing_assignments
    bulk_assignment.save!
    existing_assignments.find_in_batches do |subset|
      BulkReassignment.create!(assignments: subset, bulk_assignment: bulk_assignment)
    end
  end

  def existing_assignments
    @existing_assignments ||= Assignment.where(split: split).where.not(variant: variant)
  end

  def bulk_assignment
    @bulk_assignment ||= BulkAssignment.new(admin: admin, split: split, reason: "Decision", variant: variant)
  end

  def variant_belongs_to_split
    errors.add(:variant, "#{variant} is not a valid variant for split") unless split.has_variant? variant
  end
end
