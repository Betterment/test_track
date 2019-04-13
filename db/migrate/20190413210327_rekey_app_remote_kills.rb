class RekeyAppRemoteKills < ActiveRecord::Migration[5.1]
  def change
    create_table :better_app_remote_kills, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :app, type: :uuid, null: false, foreign_key: true
      t.references :split, type: :uuid, null: false, foreign_key: true
      t.string "reason", null: false
      t.string "override_to", null: false
      t.integer "first_bad_version", array: true, null: false
      t.integer "fixed_version", array: true
      t.timestamps

      t.index ["split_id", "app_id", "reason"], unique: true
    end

    execute <<~SQL
      insert into better_app_remote_kills
      (app_id, split_id, reason, override_to, first_bad_Version, fixed_version, created_at, updated_at)
      select app_id, split_id, reason, override_to, first_bad_version, fixed_version, created_at, updated_at
      from app_remote_kills
    SQL

    drop_table :app_remote_kills

    rename_table :better_app_remote_kills, :app_remote_kills
  end
end
