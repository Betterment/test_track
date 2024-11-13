# frozen_string_literal: true

class ExperimentDetail < ActiveRecord::Base
  belongs_to :split
end
