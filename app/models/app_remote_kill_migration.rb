class AppRemoteKillMigration
  include ActiveModel::Validations

  attr_reader :app,
    :split,
    :reason,
    :first_bad_version_before_type_cast

  validate :split_must_exist
  validates :reason, presence: true

  delegate :override_to,
    :first_bad_version,
    :fixed_version,
    to: :app_remote_kill

  def initialize(params)
    @app = params[:app] || raise("Must provide app")
    @split = params[:split]
    @reason = params[:reason]
    @first_bad_version_before_type_cast = params[:first_bad_version]
    app_remote_kill.assign_attributes(
      override_to: params[:override_to],
      first_bad_version: params[:first_bad_version],
      fixed_version: params[:fixed_version]
    )
  end

  def valid?
    if destroy?
      super
    else
      app_remote_kill.valid?
    end
  end

  def errors
    if destroy?
      super
    else
      app_remote_kill.errors
    end
  end

  def save
    if destroy?
      valid? && app_remote_kill.destroy.destroyed?
    else
      app_remote_kill.save
    end
  end

  def destroy?
    first_bad_version_before_type_cast.blank?
  end

  private

  def app_remote_kill
    @app_remote_kill ||= app.remote_kills.find_or_initialize_by(split: split_model, reason: reason)
  end

  def split_model
    Split.find_by(name: split)
  end

  def split_must_exist
    errors.add(:split, "must exist") unless split_model
  end
end
