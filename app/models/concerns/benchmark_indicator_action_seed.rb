module BenchmarkIndicatorActionSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless BenchmarkIndicatorAction.count.zero?

      warn "Seeding data for BenchmarkIndicatorActions..."
      benchmark_actions_attrs =
        JSON.parse File.read File.join Rails.root,
                                       "/db/seed-data/benchmark_indicator_actions.json"
      benchmark_actions_attrs.each do |hash_attrs|
        attrs = hash_attrs.with_indifferent_access
        display_abbreviation = attrs[:benchmark_indicator_display_abbreviation]
        benchmark_indicator =
          BenchmarkIndicator.find_by_display_abbreviation!(display_abbreviation)
        BenchmarkIndicatorAction.create!(
          benchmark_indicator: benchmark_indicator,
          text: attrs[:text],
          level: attrs[:level],
          sequence: attrs[:sequence],
          action_types: attrs[:action_types],
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
