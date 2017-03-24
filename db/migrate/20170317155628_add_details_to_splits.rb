class AddDetailsToSplits < ActiveRecord::Migration
  def change
    add_column :splits, :hypothesis, :text, null: true
    add_column :splits, :assignment_criteria, :text, null: true
    add_column :splits, :description, :text, null: true
    add_column :splits, :squad_owner, :string, null: true
  end
end
