module ReferenceLibraryDocumentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    SEED_PATH = "data/reference_library_documents_from_airtable.json"

    def seed!
      warn "Seeding data for ReferenceLibraryDocuments..."
      doc_attrs = JSON.parse Rails.root.join(SEED_PATH).read
      docs = doc_attrs.map { |a| ReferenceLibraryDocument.new(a) }
      ReferenceLibraryDocument.bulk_import docs, recursive: true

      id = ReferenceLibraryDocument.last.id
      ReferenceLibraryDocument.connection.exec_query(
        "SELECT setval('public.reference_library_documents_id_seq', #{id});",
        "Update generated IDs sequence to match imported data"
      )
    end

    def unseed!
      ReferenceLibraryDocument.destroy_all
      ReferenceLibraryDocument.connection.exec_query(
        "SELECT setval('public.reference_library_documents_id_seq', 1, false);"
      )
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
      puts "Destroying the existing ReferenceLibraryDocuments and cascading to ActionDocuments..."
      unseed!

      puts "Fetching all documents..."
      new_docs = Airtable::ReferenceLibraryDocument.fetch_approved
      puts "Found #{new_docs.size} new documents."
      return if new_docs.empty?

      puts "Looking up actions for new documents..."

      action_map = BenchmarkIndicatorAction.all.map { |a| [a.text, a] }.to_h

      import_docs =
        new_docs.map do |d|
          attrs = d.to_attrs
          actions =
            attrs
              .delete(:benchmark_indicator_actions)
              .map { |a| action_map.fetch(a) }
          attrs[:benchmark_indicator_actions] = actions
          print "."
          ReferenceLibraryDocument.new(attrs)
        end
      print "\n"

      puts "Adding documents to database..."
      ReferenceLibraryDocument.bulk_import import_docs, recursive: true
      write_seed!
    end
  end
end
