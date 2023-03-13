class CreateJoinTablePlansDiseases < ActiveRecord::Migration[5.2]
  def change
    create_join_table :plans, :diseases, table_name: :plan_diseases do |t|
      t.index %i[plan_id disease_id], unique: true
    end
    add_foreign_key :plan_diseases, :plans
    add_foreign_key :plan_diseases, :diseases
  end
end
