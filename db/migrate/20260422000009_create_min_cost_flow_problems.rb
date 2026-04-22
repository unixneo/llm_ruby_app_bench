class CreateMinCostFlowProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :min_cost_flow_problems do |t|
      t.string :name, null: false
      t.integer :nodes, null: false
      t.text :edges, null: false
      t.integer :source, null: false
      t.integer :sink, null: false
      t.integer :demand, null: false
      t.text :description
      t.timestamps
    end

    add_index :min_cost_flow_problems, :name, unique: true
  end
end
