class CreatePrompts < ActiveRecord::Migration[7.2]
  def change
    create_table :prompts do |t|
      t.string :prompt_id, null: false
      t.text :description

      t.timestamps
    end

    add_index :prompts, :prompt_id, unique: true
  end
end
