class SplitDetail
  include ActiveModel::Model

  attr_accessor :split, :hypothesis, :assignment_criteria, :description, :owner, :location, :platform
  validates :hypothesis, :assignment_criteria, :description, :owner, :location, :platform, presence: true
  validates :platform, inclusion: { in: %w(mobile desktop) }

  def initialize(params)
    raise 'A split is required to create split details' unless params[:split].present?
    super
  end

  def save
    if valid?
      update_split!
      true
    else
      false
    end
  end

  def assignment_criteria
    @assignment_criteria ||= split.assignment_criteria
  end

  def description
    @description ||= split.description
  end

  def hypothesis
    @hypothesis ||= split.hypothesis
  end

  def owner
    @owner ||= split.owner
  end

  def platform
    @platform ||= split.platform
  end

  def location
    @location ||= split.location
  end

  private

  def update_split!
    split.update!(
      hypothesis: hypothesis,
      assignment_criteria: assignment_criteria,
      description: description,
      owner: owner,
      location: location,
      platform: platform
    )
  end
end
