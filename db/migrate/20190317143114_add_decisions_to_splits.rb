class AddDecisionsToSplits < ActiveRecord::Migration[5.1]
  def change
    add_column :splits, :decided_at, :timestamp
  end
end
