class GithubSearch
  include Singleton

  GITHUB_ORGANIZATION_ENV_VARIABLE_NAME = 'GITHUB_ORGANIZATION'.freeze

  class << self
    private :instance

    delegate :github_organization, :configured?, :build_split_search_url, to: :instance
  end

  def github_organization
    ENV.fetch(GITHUB_ORGANIZATION_ENV_VARIABLE_NAME, nil)
  end

  def configured?
    github_organization.present?
  end

  def build_split_search_url(split)
    raise "Cannot build split search url because #{GITHUB_ORGANIZATION_ENV_VARIABLE_NAME} is not set" unless configured?

    "https://github.com/search?q=org%3A#{github_organization}+#{split.name}&type=code"
  end
end
