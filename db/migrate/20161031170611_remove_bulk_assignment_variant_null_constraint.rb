class RemoveBulkAssignmentVariantNullConstraint < ActiveRecord::Migration
  def change
    change_column :bulk_assignments, :variant, :string, :null => true
  end
end
