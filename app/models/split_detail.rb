class SplitDetail
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include DelegateAttribute

  attr_accessor :split
  delegate :name, :variants, to: :split
  delegate_attribute :hypothesis, :assignment_criteria, :description, :owner, :location, :platform, to: :split

  validates :hypothesis, presence: true, if: -> { hypothesis.present? }
  validates :assignment_criteria, presence: true, if: -> { assignment_criteria.present? }
  validates :description, presence: true, if: -> { description.present? }
  validates :owner, presence: true, if: -> { owner.present? }
  validates :location, presence: true, if: -> { location.present? }
  validates :platform, presence: true, if: -> { platform.present? }

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

  def save
    if valid?
      split.save!
      true
    else
      false
    end
  end
end
