class AppRemoteKillMigration
  include ActiveModel::Validations

  attr_reader :app,
    :split,
    :reason

  delegate :override_to,
    :first_bad_version,
    :fixed_version,
    :save,
    :valid?,
    :errors,
    to: :app_remote_kill

  def initialize(params)
    @app = params[:app] || raise("Must provide app")
    @split = params[:split]
    @reason = params[:reason]
    app_remote_kill.assign_attributes(
      override_to: params[:override_to],
      first_bad_version: params[:first_bad_version],
      fixed_version: params[:fixed_version]
    )
  end

  private

  def app_remote_kill
    @app_remote_kill ||= app.remote_kills.find_or_initialize_by(split: split_model, reason: reason)
  end

  def split_model
    Split.find_by(name: split)
  end
end
