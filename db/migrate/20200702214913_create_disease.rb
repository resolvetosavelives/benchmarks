class CreateDisease < ActiveRecord::Migration[5.2]
  def change
    create_table :diseases do |t|
      t.string :display
      t.string :name
      t.timestamps
    end
  end
end
