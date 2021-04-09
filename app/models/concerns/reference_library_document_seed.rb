module ReferenceLibraryDocumentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      warn "Seeding data for ReferenceLibraryDocuments..."
      ReferenceLibraryDocument.import!
    end

    def unseed!
      ReferenceLibraryDocument.destroy_all
    end
  end
end
