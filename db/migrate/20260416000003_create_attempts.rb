class CreateAttempts < ActiveRecord::Migration[7.2]
  def change
    create_table :attempts do |t|
      t.string :prompt_id, null: false
      t.references :challenge, null: false, foreign_key: true
      t.string :fixture_name, null: false
      t.text :candidate_result, null: false
      t.text :reference_result, null: false
      t.float :difference, null: false, default: 0.0
      t.string :status, null: false, default: "pending_interpretation"

      t.timestamps
    end

    add_index :attempts, :prompt_id
    add_index :attempts, [:prompt_id, :fixture_name], unique: true
  end
end
