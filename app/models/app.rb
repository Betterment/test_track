class App < ActiveRecord::Base
  has_many :splits, foreign_key: :owner_app_id, dependent: :nullify, inverse_of: :owner_app
  has_many :identifier_types, foreign_key: :owner_app_id, dependent: :nullify, inverse_of: :owner_app
  has_many :feature_completions, class_name: "AppFeatureCompletion", dependent: :nullify

  validates :name, :auth_secret, presence: true
  validates :name, uniqueness: true

  validate :auth_secret_must_be_sufficiently_strong

  def define_build(params = {})
    ::App::Build.new(params.merge(app_id: id))
  end

  private

  def auth_secret_must_be_sufficiently_strong
    return if auth_secret && auth_secret.size >= 43

    errors.add(:auth_secret, "must be at least 32-bytes, Base64 encoded")
  end

  class Build
    attr_reader :app_id, :version, :built_at

    def initialize(app_id:, version:, built_at:)
      @app_id = app_id
      @version = AppVersion.new(version)
      @built_at = built_at
    end
  end
end
