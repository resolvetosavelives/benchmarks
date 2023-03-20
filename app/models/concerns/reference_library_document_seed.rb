module ReferenceLibraryDocumentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    SEED_PATH = "data/reference_library_documents_from_airtable.json"

    def seed!
      unless ReferenceLibraryDocument.count.zero?
        puts "Destroying the existing ReferenceLibraryDocuments and cascading to ActionDocuments..."
        unseed!
      end

      warn "Seeding data for ReferenceLibraryDocuments..."
      doc_attrs = JSON.parse Rails.root.join(SEED_PATH).read
      docs = doc_attrs.map { |a| ReferenceLibraryDocument.new(a) }
      ReferenceLibraryDocument.bulk_import docs, recursive: true

      # Update generated IDs sequence to match imported data
      ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
    end

    def unseed!
      ReferenceLibraryDocument.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
    end

    def write_seed!
      doc_attrs =
        ReferenceLibraryDocument
          .includes(:benchmark_indicator_actions)
          .all
          .map do |doc|
            doc.attributes.merge(
              "benchmark_indicator_action_ids" =>
                doc.benchmark_indicator_action_ids
            )
          end
      File.write SEED_PATH, JSON.dump(doc_attrs)
    end

    def update_from_airtable!
      ReferenceLibraryDocument.transaction do
        Rails
          .logger.info "Destroying the existing ReferenceLibraryDocuments and cascading to ActionDocuments..."
        unseed!

        Rails.logger.info "Fetching all documents..."
        new_docs = Airtable::ReferenceLibraryDocument.fetch_approved
        Rails.logger.info "Found #{new_docs.size} new documents."
        return if new_docs.empty?

        Rails.logger.info "Looking up actions for new documents..."

        action_map = BenchmarkIndicatorAction.all.map { |a| [a.text, a] }.to_h

        import_docs =
          new_docs.map do |d|
            attrs = d.to_attrs
            actions =
              attrs
                .delete(:benchmark_indicator_actions)
                .map { |a| action_map.fetch(a) }
            attrs[:benchmark_indicator_actions] = actions
            Rails.logger << "." if Rails.logger.info?
            ReferenceLibraryDocument.new(attrs)
          end
        Rails.logger << "\n" if Rails.logger.info?

        Rails.logger.info "Adding documents to database..."
        ReferenceLibraryDocument.bulk_import import_docs, recursive: true
        write_seed!
      end
    end
  end
end
