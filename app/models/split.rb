class Split < ActiveRecord::Base
  belongs_to :owner_app, required: true, class_name: "App", inverse_of: :splits

  has_many :previous_split_registries, dependent: :nullify
  has_many :assignments, -> { for_presentation }, dependent: :nullify, inverse_of: :split
  has_many :bulk_assignments, dependent: :nullify
  has_many :variant_details, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :registry, presence: true

  validate :name_must_be_snake_case
  validate :name_must_not_include_new
  validate :name_must_not_end_with_test
  validate :variants_must_be_snake_case
  validate :registry_weights_must_sum_to_100
  validate :registry_weights_must_be_integers
  validate :registry_must_have_winning_variant_if_decided

  enum platform: %i(mobile desktop)

  before_validation :cast_registry

  scope :for_presentation, ->(app_build: nil) do
    app_build.present? ? for_app_build(app_build) : active
  end

  scope :for_app_build, ->(app_build) do
    active(as_of: app_build.built_at)
      .with_feature_incomplete_knockouts_for(app_build)
  end

  scope :active, ->(as_of: nil) do
    as_of ? where('splits.finished_at is null or splits.finished_at > ?', as_of) : where(finished_at: nil)
  end

  scope :with_feature_incomplete_knockouts_for, ->(app_build) do
    previous_selects = all.arel.projections
    except(:select)
      .select(
        previous_selects,
        Arel::SelectManager.new
          .where(arel_excluding_incomplete_features_for(app_build).not)
          .exists
          .as('feature_incomplete')
      )
      .readonly
  end

  scope :excluding_incomplete_features_for, ->(app_build) do
    where(arel_excluding_incomplete_features_for(app_build))
  end

  class << self
    private

    def arel_excluding_incomplete_features_for(app_build)
      Arel::Nodes::Or.new(
        arel_table[:feature_gate].eq(false),
        AppFeatureCompletion.select(1).satisfied_by(app_build).arel.exists
      )
    end
  end

  def detail
    @detail ||= SplitDetail.new(split: self)
  end

  def has_details?
    %w(hypothesis assignment_criteria description owner location platform).any? { |attr| public_send(attr).present? }
  end

  def has_variant?(variant)
    registry.key?(variant.to_s)
  end

  def variants
    registry ? registry.keys : []
  end

  def variant_weight(variant)
    registry[variant]
  end

  def finished?
    finished_at.present?
  end

  def reassign_weight(weighting_registry)
    now = Time.zone.now
    previous_split_registries.build(registry: registry, created_at: updated_at, updated_at: now, superseded_at: now)
    self.registry = weighting_registry
    self.updated_at = now
  end

  def build_config(params = {})
    SplitUpsert.new({ weighting_registry: registry }.merge(params).merge(name: name, app: owner_app))
  end

  def reconfigure!(params = {})
    build_config(params).save!.tap do
      reload
    end
  end

  def reweight!(weighting_registry)
    reconfigure!(weighting_registry: weighting_registry)
  end

  def assignment_count_for_variant(variant)
    assignments.where(variant: variant).count(:id)
  end

  def build_decision(params = {})
    Decision.new(params.merge(split: self))
  end

  def create_decision!(params = {})
    build_decision(params).tap(&:save!)
  end

  def registry
    if try(:feature_incomplete?)
      knock_out_weightings(super)
    else
      super
    end
  end

  private

  def knock_out_weightings(registry_hash, to: "false")
    found_key = false
    knocked_out_registry = registry_hash.each_with_object({}) do |(k, _), h|
      h[k] = (k.to_s == to.to_s ? (found_key = true && 100) : 0)
    end
    if found_key
      knocked_out_registry
    else
      logger.error "Failed to knock out weightings of split #{name.inspect} because variant #{to.inspect} not found."
      registry_hash
    end
  end

  def name_must_be_snake_case
    errors.add(:name, "must be snake_case: #{name.inspect}") if name_not_underscored?
  end

  def name_must_not_include_new
    errors.add(:name, <<-ERROR_MESSAGE) if name_contains_new?
      should not contain the ambiguous word 'new'. If expressing timing, refer to absolute time like 'late_2015'. If expressing creation use 'create'.
    ERROR_MESSAGE
  end

  def name_must_not_end_with_test
    errors.add(:name, "should not end with 'test', as it is redundant. All splits are testable.") if name_ends_with_test?
  end

  def variants_must_be_snake_case
    errors.add(:registry, "all variants must be snake_case: #{variants.inspect}") if variants_not_underscored?
  end

  def registry_must_have_winning_variant_if_decided
    errors.add(:registry, "must have a winning variant if decided") if decided_at.present? && registry.values.none? { |v| v == 100 }
  end

  def registry_weights_must_sum_to_100
    sum = registry && registry.values.sum
    errors.add(:registry, "must contain weights that sum to 100% (got #{sum})") unless sum == 100
  end

  def registry_weights_must_be_integers
    return if registry.blank?
    return unless @registry_before_type_cast.values.any? { |w| w.to_i.to_s != w.to_s }

    errors.add(:registry, "all weights must be integers")
  end

  def name_not_underscored?
    name && !underscored?(name)
  end

  def name_contains_new?
    name && dasherized_name.match(/\bnew\b/i).present?
  end

  def name_ends_with_test?
    name && dasherized_name.match(/\btest\z/i).present?
  end

  def variants_not_underscored?
    variants.any? { |k| !underscored?(k) }
  end

  def underscored?(string)
    string.to_s == string.to_s.underscore
  end

  def dasherized_name
    name && name.to_s.dasherize
  end

  def cast_registry
    @registry_before_type_cast = registry
    self.registry = registry.transform_values { |w| w.to_i } if registry
  end
end
