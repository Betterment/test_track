module ApplicationHelper
  def identifier_types
    IdentifierType.all.reverse
  end

  def percentage(ratio)
    "#{(ratio * 100).round}%"
  end

  def variant_screenshot_path(detail)
    admin_split_screenshot_path(detail.filename, split_id: detail.split.id) if detail.screenshot_file_name?
  end
end
