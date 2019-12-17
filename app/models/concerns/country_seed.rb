module CountrySeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless Country.count.zero?

      warn "Seeding data for Countries..."
      eval_indicators_attrs = JSON.parse(
        File.read(
          File.join(Rails.root, "/db/seed-data/ISO-3166-Countries-with-Regional-Codes-all.json")
        )
      )
      eval_indicators_attrs.each do |attrs|
        Country.create(
          name: attrs["name"],
          alpha2: attrs["alpha-2"],
          alpha3: attrs["alpha-3"],
          country_code: attrs["country-code"],
          region: attrs["region"],
          sub_region: attrs["sub-region"],
          intermediate_region: attrs["intermediate-region"],
          region_code: attrs["region-code"],
          sub_region_code: attrs["sub-region-code"],
          intermediate_region_code: attrs["intermediate-region-code"],
        )
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query(
        "DELETE FROM #{table_name}"
      )
    end
  end
end
