class AddLocationAndPlatformToSplits < ActiveRecord::Migration
  def change
    add_column :splits, :location, :string, null: true
    add_column :splits, :platform, :integer, null: true
  end
end
