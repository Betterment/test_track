require 'digest'

class VariantCalculator
  attr_reader :visitor_id, :split

  def initialize(opts = {})
    @visitor_id = opts.delete(:visitor_id)
    raise "Must provide visitor_id" unless visitor_id
    @split = opts.delete(:split)
    raise "Must provide split" unless split
    raise "unknown opts: #{opts.keys.to_sentence}" if opts.present?
  end

  def variant
    @variant ||= _variant
  end

  def _variant
    bucket_ceiling = 0
    sorted_variants.detect do |variant|
      bucket_ceiling += weighting[variant]
      bucket_ceiling > assignment_bucket
    end
  end

  def sorted_variants
    weighting.keys.sort
  end

  def weighting
    @weighting ||= split.registry
  end

  def assignment_bucket
    @assignment_bucket ||= hash_fixnum % 100
  end

  def hash_fixnum
    split_visitor_hash.slice(0, 8).to_i(16)
  end

  def split_visitor_hash
    Digest::MD5.new.update(split.name + visitor_id.to_s).hexdigest
  end
end
