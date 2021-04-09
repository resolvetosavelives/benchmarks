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

    def update_from_airtable!
      last_edit =
        ReferenceLibraryDocument.order(:last_modified).last&.last_modified
      new_docs =
        Airtable::ReferenceLibraryDocument.fetch_approved(since: last_edit)
      return if new_docs.empty?

      now = Time.now
      doc_attrs =
        new_docs.map { |d| d.to_attrs.merge(created_at: now, updated_at: now) }
      ReferenceLibraryDocument.insert_all(doc_attrs)
    end
  end
end
