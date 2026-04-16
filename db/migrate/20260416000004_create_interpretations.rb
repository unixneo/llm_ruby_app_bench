class CreateInterpretations < ActiveRecord::Migration[7.2]
  def change
    create_table :interpretations do |t|
      t.references :attempt, null: false, foreign_key: true
      t.string :classification, null: false
      t.text :notes

      t.timestamps
    end
  end
end
