class VariantRetirement
  include ActiveModel::Model

  attr_accessor :split_id, :retiring_variant, :admin

  def save!
    Assignment.transaction do
      retiring_assignment_ids_by_active_variant.each do |variant, assignment_ids|
        unless assignment_ids.empty?
          bulk_assignment = create_bulk_assignment_for_variant(variant)
          BulkReassignment.create!(assignments: assignment_ids, bulk_assignment: bulk_assignment)
        end
      end
    end
  end

  def self.create!(params)
    new(params).tap(&:save!)
  end

  private

  def retiring_assignment_ids_by_active_variant
    @retiring_assignment_ids_by_active_variant ||= _retiring_assignment_ids_by_active_variant
  end

  def _retiring_assignment_ids_by_active_variant
    variant_map = Hash[sorted_active_variants.map { |v| [v, []] }]
    retiring_assignments.select(:id).find_each do |assignment|
      variant_map[random_active_variant] << assignment.id
    end
    variant_map
  end

  def create_bulk_assignment_for_variant(variant)
    admin.bulk_assignments.create(reason: "Retiring #{retiring_variant}", split: split, variant: variant)
  end

  def retiring_assignments
    @retiring_assignments ||= split.assignments.where(variant: retiring_variant)
  end

  def sorted_active_variants
    @sorted_active_variants ||= split.variants.select { |v| split.variant_weight(v).positive? }.sort
  end

  def random_active_variant
    sorted_active_variant_weight_gradient[SecureRandom.random_number(100)]
  end

  def sorted_active_variant_weight_gradient
    @sorted_active_variant_weight_gradient ||= sorted_active_variants.flat_map do |variant|
      [variant] * split.variant_weight(variant)
    end
  end

  def split
    @split ||= Split.find(split_id)
  end
end
