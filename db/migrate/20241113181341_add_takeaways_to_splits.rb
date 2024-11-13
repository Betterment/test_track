class AddTakeawaysToSplits < ActiveRecord::Migration[7.0]
  def change
    add_column :splits, :takeaways, :text
  end
end
