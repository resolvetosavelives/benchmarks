module ReferenceLibraryDocumentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    SEED_PATH = "data/reference_library_documents_from_airtable.json"

    def seed!
      warn "Seeding data for ReferenceLibraryDocuments..."
      doc_attrs = JSON.parse Rails.root.join(SEED_PATH).read
      docs = doc_attrs.map { |a| ReferenceLibraryDocument.new(a) }
      ReferenceLibraryDocument.bulk_import docs

      id = ReferenceLibraryDocument.last.id
      ReferenceLibraryDocument.connection.exec_query(
        "SELECT setval('public.reference_library_documents_id_seq', #{id});",
        "Update generated IDs sequence to match imported data"
      )
    end

    def unseed!
      ReferenceLibraryDocument.destroy_all
    end

    def dump_seed_file!
      doc_attrs =
        ReferenceLibraryDocument.all.map do |doc|
          doc.attributes.merge(
            "benchmark_indicator_action_ids" =>
              doc.benchmark_indicator_action_ids
          )
        end
      File.write SEED_PATH, JSON.dump(doc_attrs)
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

      action_map =
        BenchmarkIndicatorAction.pluck(:text, :id).map do |t, i|
          [t.freeze, i]
        end.to_h
      doc_attrs.each do |attrs|
        action_ids =
          attrs
            .delete(:benchmark_indicator_actions)
            .map { |a| action_map.fetch(a.freeze) }
        attrs[:benchmark_indicator_action_ids] = action_ids
      end if ReferenceLibraryDocument.reflect_on_association(
        :benchmark_indicator_actions
      )

      ReferenceLibraryDocument.insert_all(doc_attrs)
    end
  end
end
