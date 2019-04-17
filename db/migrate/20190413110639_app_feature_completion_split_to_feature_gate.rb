class AppFeatureCompletionSplitToFeatureGate < ActiveRecord::Migration[5.1]
  def change
    rename_column :app_feature_completions, :split_id, :feature_gate_id
  end
end
