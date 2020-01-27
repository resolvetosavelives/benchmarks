class AddTermColumnToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :term, :integer
  end
end
