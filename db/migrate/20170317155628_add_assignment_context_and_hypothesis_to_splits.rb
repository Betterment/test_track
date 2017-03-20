class AddAssignmentContextAndHypothesisToSplits < ActiveRecord::Migration
  def change
    add_column :splits, :hypothesis, :text, null: true
    add_column :splits, :assignment_context, :text, null: true
  end
end
