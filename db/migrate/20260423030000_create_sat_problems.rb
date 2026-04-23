class CreateSatProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :sat_problems do |t|
      t.string :name, null: false
      t.integer :num_vars, null: false
      t.text :clauses, null: false
      t.boolean :satisfiable, null: false
      t.text :description
      t.timestamps
    end

    add_index :sat_problems, :name, unique: true
  end
end
