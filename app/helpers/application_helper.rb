module ApplicationHelper
  def identifier_types
    IdentifierType.all.reverse
  end

  def percentage(ratio)
    "#{(ratio * 100).round}%"
  end

  def github_search_enabled?
    ENV['GITHUB_ORGANIZATION'].present?
  end

  def github_search_url(split)
    return nil unless github_search_enabled?

    "https://github.com/search?q=org%3A#{ENV['GITHUB_ORGANIZATION']}+#{split.name}&type=code"
  end
end
