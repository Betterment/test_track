class SplitRegistry
  include ActiveModel::Validations

  validates :as_of, presence: true
  # We want to make sure the client is shipping us high-precision ISO
  # timestamps so we choose to allow timestamps at either millisecond or second
  # precision based on the W3C interpretation of iso8601 from this SO answer:
  #
  # https://stackoverflow.com/a/3143231
  validates :as_of, format: {
    with: /\A\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d(.\d+)?([+-][0-2]\d:[0-5]\d|Z)\z/, allow_blank: true
  }

  def initialize(as_of:)
    @as_of = as_of
  end

  def splits
    Split.active(as_of:)
  end

  def experience_sampling_weight
    Rails.configuration.experience_sampling_weight
  end

  private

  attr_reader :as_of
end
