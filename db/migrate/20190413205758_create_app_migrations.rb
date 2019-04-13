class CreateAppMigrations < ActiveRecord::Migration[5.1]
  def change
    create_table :app_migrations, id: :uuid, default: -> { "uuid_generate_v4()" } do |t|
      t.references :app, type: :uuid, null: :false, foreign_key: true
      t.string :version, null: false, unique: true
    end

    add_index :app_migrations, [:app_id, :version], unique: true
  end
end
