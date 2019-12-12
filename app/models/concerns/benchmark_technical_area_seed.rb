module BenchmarkTechnicalAreaSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      if BenchmarkTechnicalArea.count.zero?
        benchmark_ta_attrs = JSON.load File.open File.join Rails.root, "/db/seed-data/benchmark_technical_areas.json"
        benchmark_ta_attrs.each do |hash_attrs|
          attrs = hash_attrs.with_indifferent_access
          BenchmarkTechnicalArea.create!(
            text: attrs[:text],
            sequence: attrs[:sequence]
          )
        end
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name} CASCADE"
      )
    end
  end
end
