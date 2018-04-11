class CreateDecisionJob < ApplicationJob
  def perform(split, attrs)
    split.create_decision!(attrs)
  end
end
