class VariantDetail
  attr_reader :split, :variant, :weight, :assignment_count

  def initialize(split, variant)
    @split = split
    @variant = variant
    @weight = split.variant_weight(variant)
    @assignment_count = split.assignment_count_for_variant(variant)
  end

  def retirable?
    weight == 0 && assignment_count > 0
  end
end
