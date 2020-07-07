class ModifyActionsForDiseases < ActiveRecord::Migration[5.2]
  def change
    add_column :benchmark_indicator_actions, :disease_id, :integer
    add_foreign_key :benchmark_indicator_actions, :diseases
  end
end
