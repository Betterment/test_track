class SplitRegistry
  include Singleton

  def splits
    Split.active
  end

  def experience_sampling_weight
    @experience_sampling_weight ||= _experience_sampling_weight
  end

  private

  def _experience_sampling_weight
    Integer(ENV.fetch('EXPERIENCE_SAMPLING_WEIGHT', '1')).tap do |weight|
      raise <<~TEXT if weight.negative?
        EXPERIENCE_SAMPLING_WEIGHT, if specified, must be greater than or equal to 0. Use 0 to disable experience events.
      TEXT
    end
  end
end
