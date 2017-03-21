class VariantPresenter < SimpleDelegator
  def weight
    @weight ||= split.variant_weight(variant)
  end

  def assignment_count
    @assignment_count ||= split.assignment_count_for_variant(variant)
  end

  def retirable?
    weight == 0 && assignment_count > 0
  end
end
