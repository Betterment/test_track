class BackfillAssignments < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    temp_assignments = Class.new(ActiveRecord::Base) do
      self.table_name = "assignments"
    end
    temp_assignments.in_batches(of: 10_000) do |batch|
      batch.update_all(force: false)
      sleep(0.1)
    end

    temp_previous_assignments = Class.new(ActiveRecord::Base) do
      self.table_name = "previous_assignments"
    end
    temp_previous_assignments.in_batches(of: 10_000) do |batch|
      batch.update_all(force: false)
      sleep(0.1)
    end

    temp_bulk_assignments = Class.new(ActiveRecord::Base) do
      self.table_name = "bulk_assignments"
    end
    temp_bulk_assignments.in_batches(of: 10_000) do |batch|
      batch.update_all(force: false)
      sleep(0.1)
    end
  end
end
