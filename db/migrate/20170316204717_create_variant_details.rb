class CreateVariantDetails < ActiveRecord::Migration
  def change
    create_table :variant_details, id: :uuid do |t|
      t.uuid :split_id, null: false, index: true
      t.string :variant, null: false
      t.string :display_name, null: false
      t.text :description, null: false

      t.timestamps null: false
    end

    add_foreign_key :variant_details, :splits
    add_index :variant_details, [:split_id, :variant], unique: true
  end
end
