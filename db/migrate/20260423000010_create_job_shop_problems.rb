class CreateJobShopProblems < ActiveRecord::Migration[7.2]
  def change
    create_table :job_shop_problems do |t|
      t.string :name, null: false
      t.text :jobs, null: false
      t.text :description
      t.timestamps
    end

    add_index :job_shop_problems, :name, unique: true
  end
end
