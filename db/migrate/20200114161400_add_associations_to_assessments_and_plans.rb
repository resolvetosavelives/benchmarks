class AddAssociationsToAssessmentsAndPlans < ActiveRecord::Migration[5.2]
  def change
    # changes to assessment_publications table
    remove_column :assessment_publications, :name
    add_column :assessment_publications, :abbrev, :string, limit: 10
    add_column :assessment_publications, :revision, :string, limit: 10

    # changes to assessments table
    add_column :assessments, :assessment_publication_id, :integer
    add_foreign_key :assessments, :assessment_publications
    remove_column :assessments, :assessment_type
    remove_column :assessments, :scores

    # new table assessment_scores
    create_table :assessment_scores do |t|
      t.integer :assessment_id, null: false
      t.integer :assessment_indicator_id, null: false
      t.integer :value, null: false
    end
    add_foreign_key :assessment_scores, :assessments
    add_foreign_key :assessment_scores, :assessment_indicators

    # changes to plans table
    add_column :plans, :assessment_id, :integer
    add_foreign_key :plans, :assessments
    remove_column :plans, :assessment_type
    remove_column :plans, :country_alpha3

    # drop plan_benchmark_indicators table
    drop_table :plan_benchmark_indicators

    # new table plan_goals
    create_table :plan_goals do |t|
      t.integer :plan_id, null: false
      t.integer :assessment_indicator_id, null: false
      t.integer :benchmark_indicator_id, null: false
      t.integer :value, null: false
    end
    add_foreign_key :plan_goals, :plans
    add_foreign_key :plan_goals, :assessment_indicators
    add_foreign_key :plan_goals, :benchmark_indicators
  end
end
