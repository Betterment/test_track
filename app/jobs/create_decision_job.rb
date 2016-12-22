class CreateDecisionJob < ActiveJob::Base
  def perform(split, attrs)
    split.create_decision!(attrs)
  end
end
