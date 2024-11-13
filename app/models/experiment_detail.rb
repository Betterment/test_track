# frozen_string_literal: true

class ExperimentDetail < ActiveRecord::Base
  belongs_to :split

  def start_date
    super || split.created_at.to_date
  end

  def end_date
    super || split.decided_at&.to_date
  end

  def control_variant
    super || split.registry.keys.find { |v| v == 'control' }
  end

  def self.available_tests
    @available_tests ||= {}
  end

  def self.available_segments
    @available_segments ||= {}
  end
end
