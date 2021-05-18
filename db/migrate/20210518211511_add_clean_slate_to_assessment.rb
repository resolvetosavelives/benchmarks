class AddCleanSlateToAssessment < ActiveRecord::Migration[6.1]
  def change
    add_column :assessments, :clean_slate, :boolean, default: false, null: false
  end
end
