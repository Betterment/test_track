class AppIdentifierClaim
  include ActiveModel::Model

  attr_accessor :app_name, :version_number, :build_timestamp, :identifier_type, :value, :visitor_id

  validate :build_path_must_be_valid
  validate :identifier_claim_must_be_valid

  def save
    if valid?
      identifier_claim.save!
    else
      false
    end
  end

  def visitor
    identifier_claim.identifier.visitor
  end

  def app_build # rubocop:disable Rails/Delegate
    build_path.app_build
  end

  private

  def build_path
    @build_path ||= AppVersionBuildPath.new(
      app_name: app_name,
      version_number: version_number,
      build_timestamp: build_timestamp
    )
  end

  def identifier_claim
    @identifier_claim ||= IdentifierClaim.new(
      identifier_type: identifier_type,
      value: value,
      visitor_id: visitor_id
    )
  end

  def build_path_must_be_valid
    errors.merge!(build_path.errors) unless build_path.valid?
  end

  def identifier_claim_must_be_valid
    errors.merge!(identifier_claim.errors) unless identifier_claim.valid?
  end
end
