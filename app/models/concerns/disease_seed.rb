module DiseaseSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return if Disease.count == 2  # Influenza, Cholera

      warn "Seeding data for Diseases..."
      Disease.create!(display: 'Influenza', name: 'influenza') unless Disease.find_by_name('influenza').present?
      Disease.create!(display: 'Cholera', name: 'cholera') unless Disease.find_by_name('cholera').present?
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query("DELETE FROM #{table_name}")
    end
  end
end
