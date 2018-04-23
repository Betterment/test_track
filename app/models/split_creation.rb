class SplitCreation
  include ActiveModel::Model

  attr_accessor :app, :name
  attr_reader :weighting_registry

  validate :split_must_be_valid

  def save
    split.reassign_weight(merged_registry) unless split.registry == merged_registry
    return false unless valid?
    split.save
  end

  def save!
    save || raise(errors.full_messages.to_sentence)
  end

  def self.create(params)
    new(params).tap(&:save)
  end

  def weighting_registry=(registry)
    @weighting_registry = registry.to_h.stringify_keys
  end

  def split
    @split ||= app.splits.create_with(registry: merged_registry, feature_gate: feature_gate?).find_or_initialize_by(name: name)
  end

  def feature_gate?
    name.end_with?("_enabled")
  end

  private

  def zeroed_registry
    found_split ? found_split.registry.keys.each_with_object({}) { |split_name, r| r[split_name] = 0 } : {}
  end

  def merged_registry
    @merged_registry ||= zeroed_registry.merge(weighting_registry)
  end

  def found_split
    @found_split ||= app.splits.find_by(name: name)
  end

  def split_must_be_valid
    return if split.valid?
    split.errors[:name].each { |e| errors.add(:name, e) }
    split.errors[:registry].each { |e| errors.add(:weighting_registry, e) }
  end
end
