class CreateDecisionJob < ActiveJob::Base
  def perform(split, params)
    split.create_decision!(params)
  end
end
