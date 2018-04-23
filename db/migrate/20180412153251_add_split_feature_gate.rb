class AddSplitFeatureGate < ActiveRecord::Migration[5.0]
  def change
    add_column :splits, :feature_gate, :boolean, default: false, null: false
    execute "update splits set feature_gate = true where name like '%_enabled'"
  end
end
