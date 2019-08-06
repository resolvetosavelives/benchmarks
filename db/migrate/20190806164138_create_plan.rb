class CreatePlan < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :country
      t.string :assessment
      t.jsonb :capacity_map
      t.timestamps
    end
  end
end
