class SplitDetail
  include ActiveModel::Model
  include DelegateAttribute

  attr_accessor :split
  delegate_attribute :hypothesis, :assignment_criteria, :description, :owner, :location, :platform, to: :split

  validates :hypothesis, :assignment_criteria, :description, :owner, :location, :platform, presence: true
  validates :platform, inclusion: { in: %w(mobile desktop) }

  def initialize(params)
    raise 'A split is required to create split details' unless params[:split].present?
    self.split = params.delete(:split)
    super
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
