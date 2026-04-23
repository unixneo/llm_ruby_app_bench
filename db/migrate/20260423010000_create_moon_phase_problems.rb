class CreateMoonPhaseProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :moon_phase_problems do |t|
      t.string :name, null: false
      t.string :fixture_type, null: false
      t.date :observation_date
      t.integer :year
      t.integer :month
      t.float :expected_illuminated_fraction
      t.float :expected_phase_fraction
      t.string :expected_phase_name
      t.text :expected_events
      t.text :description

      t.timestamps
    end

    add_index :moon_phase_problems, :name, unique: true
  end
end
