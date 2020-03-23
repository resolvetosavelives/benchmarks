module BenchmarkIndicatorSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      seed_indicators!
      seed_many_to_many!
    end

    def seed_indicators!
      return unless BenchmarkIndicator.count.zero?

      warn "Seeding data for BenchmarkIndicators..."
      benchmark_indicators_attrs =
        JSON.load File.open File.join Rails.root,
                                      "/db/seed-data/benchmark_indicators.json"
      benchmark_indicators_attrs.each do |hash_attrs|
        attrs = hash_attrs.with_indifferent_access
        technical_area =
          BenchmarkTechnicalArea.find_by_sequence! attrs[
                                                     :technical_area_sequence
                                                   ]
        BenchmarkIndicator.create!(
          benchmark_technical_area: technical_area,
          display_abbreviation:
            "#{attrs[:technical_area_sequence]}.#{attrs[:sequence]}",
          sequence: attrs[:sequence],
          text: attrs[:text],
          objective: attrs[:objective],
        )
      end
    end

    def seed_many_to_many!
      result =
        ActiveRecord::Base.connection.exec_query(
          "SELECT COUNT(*) FROM assessment_indicators_benchmark_indicators",
        )
      existing_many_to_many_count = result.first["count"]
      return unless existing_many_to_many_count.zero?

      # Many-to-many table for "Crosswalk": AssessmentIndicators-to-BenchmarkIndicators.
      # AssessmentIndicators and BenchmarkIndicators both must already be seeded for this to work
      many_to_many_attrs =
        JSON.load File.open File.join Rails.root,
                                      "/db/seed-data/benchmark_indicators_assessment_indicators.json"
      many_to_many_attrs.each do |hash_attrs|
        attrs = hash_attrs.with_indifferent_access
        assessment_indicator =
          AssessmentIndicator.find_by_named_id!(attrs[:named_id])
        benchmark_indicator =
          BenchmarkIndicator.find_by_display_abbreviation!(
            attrs[:benchmark_indicator_display_abbreviation],
          )
        benchmark_indicator.assessment_indicators << assessment_indicator
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM assessment_indicators_benchmark_indicators CASCADE",
      )
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE",
      )
    end
  end
end
