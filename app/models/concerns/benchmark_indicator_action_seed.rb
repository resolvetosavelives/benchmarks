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

      seed_influenza_actions!
      seed_cholera_actions!
      seed_ebola_actions!
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end

    def disease_actions_are_present?(disease)
      disease.benchmark_indicator_actions.count > 0
    end

    def seed_influenza_actions!
      influenza = Disease.influenza
      return if disease_actions_are_present?(influenza)

      warn "Seeding data for Influenza Actions..."

      influenza_actions_attrs =
        JSON.parse Rails.root.join("db/seed-data/influenza_actions.json").read
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

    def seed_cholera_actions!
      cholera = Disease.cholera
      return if disease_actions_are_present?(cholera)

      warn "Seeding data for Cholera Actions..."

      cholera_actions_attrs =
        JSON.parse Rails.root.join("db/seed-data/cholera_actions.json").read
      prev_display_abbreviation = nil
      sequence = 1
      cholera_actions_attrs.each do |hash_attrs|
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
          disease_id: cholera.id
        )
        prev_display_abbreviation = display_abbreviation
      end
    end

    def seed_ebola_actions!
      ebola = Disease.ebola
      return if disease_actions_are_present?(ebola)

      warn "Seeding data for Ebola Actions..."

      ebola_actions_attrs =
        JSON.parse Rails.root.join("db/seed-data/ebola_actions.json").read
      prev_display_abbreviation = nil
      sequence = 1
      ebola_actions_attrs.each do |hash_attrs|
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
          disease_id: ebola.id
        )
        prev_display_abbreviation = display_abbreviation
      end
    end
  end
end
