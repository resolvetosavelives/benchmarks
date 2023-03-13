class AddBenchmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_publications do |t|
      t.string :name, limit: 20
      t.string :title, limit: 200
      t.string :named_id, limit: 10
      t.timestamps
    end
    add_index :assessment_publications, :named_id

    create_table :assessment_technical_areas do |t|
      t.integer :assessment_publication_id
      t.string :named_id, limit: 20
      t.integer :sequence
      t.string :text, limit: 200
      t.timestamps
    end
    add_foreign_key :assessment_technical_areas, :assessment_publications
    add_index :assessment_technical_areas, :assessment_publication_id

    create_table :assessment_indicators do |t|
      t.integer :assessment_technical_area_id
      t.string :named_id, limit: 20
      t.integer :sequence
      t.string :text, limit: 500
      t.timestamps
    end
    add_foreign_key :assessment_indicators, :assessment_technical_areas
    add_index :assessment_indicators, :assessment_technical_area_id

    create_table :benchmark_technical_areas do |t|
      t.string :text, limit: 200
      t.integer :sequence
      t.timestamps
    end

    create_table :benchmark_indicators do |t|
      t.integer :benchmark_technical_area_id
      t.integer :sequence
      t.string :display_abbreviation, limit: 10
      t.string :text, limit: 500
      t.string :objective, limit: 500
      t.timestamps
    end
    add_foreign_key :benchmark_indicators, :benchmark_technical_areas
    add_index :benchmark_indicators, :benchmark_technical_area_id

    create_table :assessment_indicators_benchmark_indicators, id: false do |t|
      t.integer :assessment_indicator_id
      t.integer :benchmark_indicator_id
    end
    add_foreign_key :assessment_indicators_benchmark_indicators,
                    :assessment_indicators
    add_foreign_key :assessment_indicators_benchmark_indicators,
                    :benchmark_indicators
    add_index(
      :assessment_indicators_benchmark_indicators,
      %i[assessment_indicator_id benchmark_indicator_id],
      unique: true,
      name: "BI_to_EI_each_pair_must_be_unique" # auto-generated name was exceeding the limit
    )
    add_index :assessment_indicators_benchmark_indicators,
              :assessment_indicator_id,
              name: "BI_to_EI_assessment_indicator_id"
    add_index :assessment_indicators_benchmark_indicators,
              :benchmark_indicator_id,
              name: "BI_to_EI_benchmark_indicator_id"

    create_table :benchmark_indicator_activities do |t|
      t.integer :benchmark_indicator_id
      t.string :text, limit: 1000
      t.integer :level
      t.integer :sequence
      t.integer :activity_types, array: true, default: []
      t.timestamps
    end
    add_foreign_key :benchmark_indicator_activities, :benchmark_indicators
    add_index :benchmark_indicator_activities, :benchmark_indicator_id

    create_table :plan_benchmark_indicators do |t|
      t.integer :plan_id
      t.integer :assessment_indicator_id
      t.integer :benchmark_indicator_id
      t.integer :score
      t.integer :goal
      t.timestamps
    end
    add_foreign_key :plan_benchmark_indicators, :plans
    add_foreign_key :plan_benchmark_indicators, :assessment_indicators
    add_foreign_key :plan_benchmark_indicators, :benchmark_indicators
    add_index :plan_benchmark_indicators, :plan_id
    add_index :plan_benchmark_indicators,
              %i[plan_id assessment_indicator_id],
              name: "plan_BIs_plan_id_and_assessment_indicator_id"
    add_index :plan_benchmark_indicators,
              %i[plan_id benchmark_indicator_id],
              name: "plan_BIs_plan_id_and_benchmark_indicator_id"

    create_table :plan_activities do |t|
      t.integer :plan_id
      t.integer :benchmark_indicator_activity_id
      t.integer :benchmark_indicator_id
      t.integer :sequence
      t.timestamps
    end
    add_foreign_key :plan_activities, :plans
    add_foreign_key :plan_activities, :benchmark_indicator_activities
    add_foreign_key :plan_activities, :benchmark_indicators
    add_index :plan_activities, :plan_id
    add_index :plan_activities, %i[plan_id benchmark_indicator_id]
  end
end
