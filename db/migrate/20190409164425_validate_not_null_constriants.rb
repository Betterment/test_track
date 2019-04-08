class ValidateNotNullConstriants < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def up
    execute "ALTER TABLE assignments VALIDATE CONSTRAINT assignments_force_check;"
    execute "ALTER TABLE previous_assignments VALIDATE CONSTRAINT previous_assignments_force_check;"
    execute "ALTER TABLE bulk_assignments VALIDATE CONSTRAINT bulk_assignments_force_check;"
  end

  def down
    # Validating doesn't need undoing
  end
end
