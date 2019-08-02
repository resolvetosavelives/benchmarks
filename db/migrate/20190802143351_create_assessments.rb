class CreateAssessments < ActiveRecord::Migration[5.2]
  def change
    create_table :assessments do |t|
      t.string :country
      t.string :assessment_type
      t.jsonb :scores

      t.timestamps
    end
    add_index :assessments, [:country, :assessment_type], unique: true
  end
end
