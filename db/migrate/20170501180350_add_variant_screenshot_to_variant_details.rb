class AddVariantScreenshotToVariantDetails < ActiveRecord::Migration
  def change
    add_attachment :variant_details, :screenshot
  end
end
