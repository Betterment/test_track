class SplitPresenter < SimpleDelegator
  def variant_details
    variants.map do |variant|
      detail = VariantDetail.find_or_initialize_by(split: __getobj__, variant: variant)
      VariantPresenter.new(detail)
    end
  end
end
