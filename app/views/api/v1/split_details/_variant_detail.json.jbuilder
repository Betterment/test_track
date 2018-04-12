json.name variant_detail.display_name
json.description variant_detail.description

json.screenshot_url variant_detail.screenshot.expiring_url(300) if variant_detail.screenshot.present?
