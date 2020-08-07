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

      seed_influenza_actions!
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE",
      )
    end

    def influenza_actions_are_present?(influenza)
      influenza.benchmark_indicator_actions.count > 0
    end

    def seed_influenza_actions!
      influenza = Disease.influenza
      return if influenza_actions_are_present?(influenza)

      warn "Seeding data for Influenza Actions..."

      influenza_actions_attrs =
          JSON.parse File.read File.join Rails.root,
                                         "/db/seed-data/influenza_actions.json"
      prev_display_abbreviation = nil
      sequence = 1
      influenza_actions_attrs.each do |hash_attrs|
        attrs = hash_attrs.with_indifferent_access
        display_abbreviation = attrs[:benchmark_indicator_display_abbreviation]
        benchmark_indicator =
            BenchmarkIndicator.find_by_display_abbreviation!(display_abbreviation)
        if prev_display_abbreviation != display_abbreviation
          sequence = 1
        else
          sequence += 1
        end
        BenchmarkIndicatorAction.create!(
          benchmark_indicator: benchmark_indicator,
          text: attrs[:action_text],
          level: nil,
          sequence: sequence,
          action_types: [attrs[:activity_type]],
          disease_id: influenza.id
        )
        prev_display_abbreviation = display_abbreviation
      end
    end
  end
end
