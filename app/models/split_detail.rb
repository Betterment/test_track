class SplitDetail
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include DelegateAttribute

  attr_accessor :split
  delegate :name, :variants, to: :split
  delegate_attribute :owner, :platform, :location, to: :split
  delegate_attribute :control_variant, :start_date, :end_date, :description,
                     :hypothesis, :assignment_criteria, :takeaways, :tests, :segments,
                     to: :experiment_detail

  validates :owner, presence: true, if: -> { split.owner_was.present? }
  validates :location, presence: true, if: -> { split.location_was.present? }
  validates :platform, presence: true, if: -> { split.platform_was.present? }

  validates :platform, inclusion: { in: %w(mobile desktop) }, allow_blank: true

  def initialize(params)
    raise 'A split is required to create split details' if params[:split].blank?

    self.split = params.delete(:split)
    super
  end

  def variant_details
    @variant_details ||= variants.map do |variant|
      VariantDetail.find_or_initialize_by(split: split, variant: variant)
    end
  end

  def experiment_detail
    split.experiment_detail || split.build_experiment_detail
  end

  def save
    if valid?
      split.save!
      split.experiment_detail.save!
      true
    else
      false
    end
  end
end
