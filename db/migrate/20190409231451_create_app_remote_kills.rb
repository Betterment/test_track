class CreateAppRemoteKills < ActiveRecord::Migration[5.1]
  def change
    create_table :app_remote_kills do |t|
      t.references :app, type: :uuid, null: false, foreign_key: true
      t.references :split, type: :uuid, null: false, foreign_key: true
      t.string "reason", null: false
      t.string "override_to", null: false
      t.integer "first_bad_version", array: true, null: false
      t.integer "fixed_version", array: true
      t.timestamps

      t.index ["split_id", "app_id", "reason"], unique: true
    end
  end
end
