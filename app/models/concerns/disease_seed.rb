module DiseaseSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return if Disease.count == 2 # Influenza, Cholera

      warn "Seeding data for Diseases..."
      unless Disease.find_by_name("influenza").present?
        Disease.create!(display: "Influenza", name: "influenza")
      end
      unless Disease.find_by_name("cholera").present?
        Disease.create!(display: "Cholera", name: "cholera")
      end
      unless Disease.find_by_name("ebola").present?
        Disease.create!(display: "Ebola", name: "ebola")
      end
    end

    def unseed!
      Disease.destroy_all
    end
  end
end
