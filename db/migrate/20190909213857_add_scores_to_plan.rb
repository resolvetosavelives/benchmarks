class AddScoresToPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :scores, :jsonb
  end
end
