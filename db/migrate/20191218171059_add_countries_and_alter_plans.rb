class AddCountriesAndAlterPlans < ActiveRecord::Migration[5.2]
  def change
    # store most of whats in the JSON file cuz why not
    create_table :countries do |t|
      t.string :name, limit: 100
      t.string :alpha2, limit: 2
      t.string :alpha3, limit: 3
      t.string :country_code, limit: 3
      t.string :region, limit: 50
      t.string :sub_region, limit: 50
      t.string :intermediate_region, limit: 50
      t.string :region_code, limit: 3
      t.string :sub_region_code, limit: 3
      t.string :intermediate_region_code, limit: 3
    end
    add_index :countries, :name, unique: true
    add_index :countries, :alpha2, unique: true
    add_index :countries, :alpha3, unique: true

    delete_all_pas   = "DELETE FROM plan_activities"
    delete_all_pbis  = "DELETE FROM plan_benchmark_indicators"
    delete_all_plans = "DELETE FROM plans"
    ActiveRecord::Base.connection.exec_query delete_all_pas
    ActiveRecord::Base.connection.exec_query delete_all_pbis
    ActiveRecord::Base.connection.exec_query delete_all_plans

    remove_column :plans, :country
    remove_column :plans, :assessment_type
    remove_column :plans, :activity_map
    remove_column :plans, :goals
    remove_column :plans, :scores

    change_table :plans do |t|
      t.column :country_alpha3, :string, limit: 3
      t.column :assessment_type, :integer
    end

    remove_column :assessments, :country
    add_column :assessments, :country_alpha3, :string, limit: 3
    add_foreign_key :assessments, :countries, column: "country_alpha3", primary_key: "alpha3"
    add_foreign_key :plans, :countries, column: "country_alpha3", primary_key: "alpha3"
  end
end
