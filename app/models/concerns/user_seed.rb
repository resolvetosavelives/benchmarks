require "faker"

module UserSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless User.count.zero?

      warn "Seeding fake user accounts..."
      countries = Country.all
      100.times do
        User.create!(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          email: Faker::Internet.email,
          country_alpha3: countries.sample.alpha3,
          password: "very fake password",
          institution: fake_institution,
          affiliation: fake_affiliation,
          access_reason: fake_access_reason,
          role: User::ROLES.first,
          status: User::STATUSES.sample
        )
      end
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query("DELETE FROM #{table_name}")
    end

    def fake_institution
      ["BCD", "GAVI", "BMG", "MoH UK", "WHO"].sample
    end

    def fake_affiliation
      ["Government", "Other", "International Org"].sample
    end

    def fake_access_reason
      ["Planning", "Research", "Costing of Plans", "Other"].sample
    end
  end
end
