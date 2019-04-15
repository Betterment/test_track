class AppVersionBuildPath
  attr_reader :app_name, :version, :built_at

  def initialize(params)
    @app_name = params[:app_name]
    @version = params[:version_number]
    @built_at = params[:build_timestamp]
  end

  def app_build
    @app_build ||= app.define_build(version: version, built_at: built_at)
  end

  private

  def app
    App.find_by!(name: app_name)
  end
end
