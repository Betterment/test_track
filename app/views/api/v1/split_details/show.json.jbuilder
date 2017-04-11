json.(@split_detail, :name, :hypothesis, :assignment_criteria, :description, :owner, :location, :platform)
json.variant_details @split_detail.variant_details, partial: 'variant_detail', as: :variant_detail
