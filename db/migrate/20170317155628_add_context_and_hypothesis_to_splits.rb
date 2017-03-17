class AddContextAndHypothesisToSplits < ActiveRecord::Migration
  def change
    add_column :splits, :hypothesis, :text, null: true
    add_column :splits, :context, :text, null: true
  end
end