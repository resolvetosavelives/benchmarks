module BenchmarkIndicatorActivitySeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless BenchmarkIndicatorActivity.count.zero?

      warn "Seeding data for BenchmarkIndicatorActivities..."
      benchmark_activities_attrs =
        JSON.parse File.read File.join Rails.root,
                                       "/db/seed-data/benchmark_indicator_activities.json"
      benchmark_activities_attrs.each do |hash_attrs|
        attrs = hash_attrs.with_indifferent_access
        display_abbreviation = attrs[:benchmark_indicator_display_abbreviation]
        benchmark_indicator =
          BenchmarkIndicator.find_by_display_abbreviation!(display_abbreviation)
        BenchmarkIndicatorActivity.create!(
          benchmark_indicator: benchmark_indicator,
          text: attrs[:text],
          level: attrs[:level],
          sequence: attrs[:sequence],
          activity_types: attrs[:activity_types],
        )
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE",
      )
    end
  end
end
