class CreateNQueensProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :n_queens_problems do |t|
      t.string :name, null: false
      t.integer :n, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :n_queens_problems, :name, unique: true
  end
end

