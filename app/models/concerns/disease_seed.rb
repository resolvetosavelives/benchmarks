module DiseaseSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      warn "Seeding data for Diseases..."
      Disease.find_or_create_by!(display: "Influenza", name: "influenza")
      Disease.find_or_create_by!(display: "Cholera", name: "cholera")
      Disease.find_or_create_by!(display: "Ebola", name: "ebola")
    end

    def unseed!
      Disease.destroy_all
    end
  end
end
