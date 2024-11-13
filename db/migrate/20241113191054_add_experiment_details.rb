class AddExperimentDetails < ActiveRecord::Migration[7.0]
  class Split < ActiveRecord::Base
    scope :with_details, -> {
      where.not(description: ['', nil])
        .or(where.not(hypothesis: ['', nil]))
        .or(where.not(assignment_criteria: ['', nil]))
    }
  end

  class ExperimentDetail < ActiveRecord::Base
    belongs_to :split, class_name: 'AddExperimentDetails::Split'
  end

  def change
    create_table :experiment_details, id: :uuid do |t|
      t.references :split, null: false, foreign_key: true, type: :uuid
      t.string :control_variant
      t.date :start_date
      t.date :end_date
      t.text :description
      t.text :hypothesis
      t.text :assignment_criteria
      t.text :takeaways
      t.json :tests, default: []
      t.json :segments, default: []
    end

    reversible do |dir|
      dir.up do
        Split.with_details.each do |split|
          ExperimentDetail.create!(
            split: split,
            description: split.description,
            hypothesis: split.hypothesis,
            assignment_criteria: split.assignment_criteria,
          )
        end
      end

      dir.down do
        ExperimentDetail.find_each do |detail|
          detail.split.update!(
            description: detail.description,
            hypothesis: detail.hypothesis,
            assignment_criteria: detail.assignment_criteria,
          )
        end
      end
    end

    remove_column :splits, :description, :text
    remove_column :splits, :hypothesis, :text
    remove_column :splits, :assignment_criteria, :text
  end
end
