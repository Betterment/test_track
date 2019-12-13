class SplitRegistrySnapshot
  include ActiveModel::Validations

  validates :timestamp, presence: true
  # We want to make sure the client is shipping us high-precision ISO
  # timestamps so we choose to allow timestamps at either millisecond or second
  # precision based on the W3C interpretation of iso8601 from this SO answer:
  #
  # https://stackoverflow.com/a/3143231
  validates :timestamp, format: {
    with: /\A\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d(.\d+)?([+-][0-2]\d:[0-5]\d|Z)\z/, allow_blank: true
  }

  def initialize(timestamp:)
    @timestamp = timestamp
  end

  def splits
    Split.active(as_of: timestamp)
  end

  def experience_sampling_weight
    @experience_sampling_weight ||= _experience_sampling_weight
  end

  private

  attr_reader :timestamp

  def _experience_sampling_weight
    Integer(ENV.fetch('EXPERIENCE_SAMPLING_WEIGHT', '1')).tap do |weight|
      raise <<~TEXT if weight.negative?
        EXPERIENCE_SAMPLING_WEIGHT, if specified, must be greater than or equal to 0. Use 0 to disable experience events.
      TEXT
    end
  end
end
