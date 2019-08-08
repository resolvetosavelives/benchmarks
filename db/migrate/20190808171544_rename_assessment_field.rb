class RenameAssessmentField < ActiveRecord::Migration[5.2]
  def change
    rename_column :plans, :assessment, :assessment_type
  end
end
