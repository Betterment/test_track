class AddNotNullConstraints < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def up
    execute "ALTER TABLE assignments ADD CONSTRAINT assignments_force_check CHECK (force IS NOT NULL) NOT VALID;"
    execute "ALTER TABLE previous_assignments ADD CONSTRAINT previous_assignments_force_check CHECK (force IS NOT NULL) NOT VALID;"
    execute "ALTER TABLE bulk_assignments ADD CONSTRAINT bulk_assignments_force_check CHECK (force IS NOT NULL) NOT VALID;"
  end
  def down
    execute "ALTER TABLE assignments DROP CONSTRAINT assignments_force_check;"
    execute "ALTER TABLE previous_assignments DROP CONSTRAINT previous_assignments_force_check;"
    execute "ALTER TABLE bulk_assignments DROP CONSTRAINT bulk_assignments_force_check;"
  end
end
