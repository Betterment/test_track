class CreateAppFeatureCompletions < ActiveRecord::Migration[5.1]
  def change
    create_table :app_feature_completions, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :app, type: :uuid, null: false, foreign_key: true
      t.references :split, type: :uuid, null: false, foreign_key: true
      t.integer :version, array: true, null: false
      t.timestamps
    end

    add_index :app_feature_completions, [:split_id, :app_id], unique: true
  end
end
