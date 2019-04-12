class BackfillAssignments < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    temp_assignments = Class.new(ActiveRecord::Base) do
      self.table_name = "assignments"
    end
    temp_assignments.in_batches.update_all(force: false)

    temp_previous_assignments = Class.new(ActiveRecord::Base) do
      self.table_name = "previous_assignments"
    end
    temp_previous_assignments.in_batches.update_all(force: false)

    temp_bulk_assignments = Class.new(ActiveRecord::Base) do
      self.table_name = "bulk_assignments"
    end
    temp_bulk_assignments.in_batches.update_all(force: false)
  end
end
