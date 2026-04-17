class CreateAssignmentProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :assignment_problems do |t|
      t.string :name, null: false
      t.integer :workers, null: false
      t.integer :tasks, null: false
      t.text :cost_matrix, null: false
      t.text :description

      t.timestamps
    end

    add_index :assignment_problems, :name, unique: true
  end
end
