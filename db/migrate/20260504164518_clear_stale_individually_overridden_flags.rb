class ClearStaleIndividuallyOverriddenFlags < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE assignments
      SET individually_overridden = false
      WHERE individually_overridden = true
        AND context IS DISTINCT FROM 'individually_overridden'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
