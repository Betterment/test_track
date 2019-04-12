class AddForceToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :force, :boolean
    change_column_default :assignments, :force, from: nil, to: false
    add_column :previous_assignments, :force, :boolean
    change_column_default :previous_assignments, :force, from: nil, to: false
    add_column :bulk_assignments, :force, :boolean
    change_column_default :bulk_assignments, :force, from: nil, to: false
  end
end
