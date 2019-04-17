class AppVersionBuildPath
  include ActiveModel::Validations

  attr_reader :app_name, :version_number, :build_timestamp

  validates :app_name, :version_number, :build_timestamp, presence: true
  # We want to make sure the client is shipping us high-precision ISO
  # timestamps so we choose to allow timestamps at either millisecond or second
  # precision based on the W3C interpretation of iso8601 from this SO answer:
  #
  # https://stackoverflow.com/a/3143231
  validates :build_timestamp, format: {
    with: /\A\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d(.\d+)?([+-][0-2]\d:[0-5]\d|Z)\z/, allow_blank: true
  }
  validate :version_number_must_be_parseable

  def initialize(params)
    @app_name = params[:app_name]
    @version_number = params[:version_number]
    @build_timestamp = params[:build_timestamp]
  end

  def app_build
    @app_build ||= begin
      raise "must be valid before retreiving app_build" unless valid?

      app.define_build(version: version_number, built_at: build_timestamp)
    end
  end

  private

  def app
    App.find_by!(name: app_name)
  end

  def version_number_must_be_parseable
    return if version_number.blank?

    AppVersion.new(version_number)
  rescue StandardError
    errors.add(:version_number, <<~ERROR)
      must be a valid in alignment with https://github.com/Betterment/test_track/blob/master/app/models/app_version.rb
    ERROR
  end
end
