class SplitDetail
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include DelegateAttribute

  attr_accessor :split

  delegate :name, :variants, to: :split
  delegate_attribute :hypothesis, :assignment_criteria, :description, :owner, :location, :platform, to: :split

  validates :hypothesis, presence: true, if: -> { split.hypothesis_was.present? }
  validates :assignment_criteria, presence: true, if: -> { split.assignment_criteria_was.present? }
  validates :description, presence: true, if: -> { split.description_was.present? }
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
      VariantDetail.find_or_initialize_by(split:, variant:)
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
