module DiseaseSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      return unless Disease.count.zero?

      warn "Seeding data for Diseases..."
      Disease.create!(display: 'Influenza', name: 'influenza')
    end

    def unseed!
      ActiveRecord::Base.connection.exec_query("DELETE FROM #{table_name}")
    end
  end
end
