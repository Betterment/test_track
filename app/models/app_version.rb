class AppVersion
  include Comparable

  DECIMAL_INTEGER = /(?:0|[1-9]\d*)/
  VERSION_REGEX = /\A(?:#{DECIMAL_INTEGER}\.){0,2}#{DECIMAL_INTEGER}\z/ # iOS rules currently, but can be relaxed from here
  MAX_LENGTH = 18 # iOS rules

  attr_reader :version_number

  def self.from_a(ary)
    ary && new(ary.map(&:to_s).join("."))
  end

  def initialize(version_number)
    version_number = version_number.to_s
    raise "version_number must be present" if version_number.blank?
    raise "version_number is too long" if version_number.length > MAX_LENGTH
    raise "version_number does not conform to format" unless version_number.match(VERSION_REGEX)
    @version_number = version_number
  end

  def to_a
    @to_a ||= version_number.split('.').map { |n| Integer(n) }
  end

  def to_s
    version_number
  end

  def to_pg_array
    "{#{to_a.join(',')}}"
  end

  def inspect
    "#<AppVersion: #{self}>"
  end

  def <=>(other)
    to_a <=> other.to_a
  end
end
