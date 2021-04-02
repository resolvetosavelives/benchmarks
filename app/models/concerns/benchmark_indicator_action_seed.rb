module BenchmarkIndicatorActionSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless BenchmarkIndicatorAction.count.zero?

      warn "Seeding data for BenchmarkIndicatorActions..."
      benchmark_actions_attrs =
        JSON.parse Rails
                     .root
                     .join("db/seed-data/benchmark_indicator_actions.json")
                     .read
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
          action_types: attrs[:action_types]
        )
      end

      seed_disease_actions!
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end

    def disease_actions_are_present?(disease)
      disease.benchmark_indicator_actions.count > 0
    end

    def seed_disease_actions!
      diseases = Disease.all.map(&:name)
      diseases.each { |d| seed_actions_for_disease!(d) }
    end

    def seed_actions_for_disease!(disease)
      disease = Disease.send(disease.to_sym)
      return if disease_actions_are_present?(disease)

      warn "Seeding data for #{disease.display} actions..."

      disease_actions_attrs =
        JSON.parse Rails
                     .root
                     .join("db/seed-data/#{disease.name}_actions.json")
                     .read
      prev_display_abbreviation = nil
      sequence = 1
      disease_actions_attrs.each do |hash_attrs|
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
          action_types: attrs[:activity_types],
          disease_id: disease.id
        )
        prev_display_abbreviation = display_abbreviation
      end
    end
  end
end
