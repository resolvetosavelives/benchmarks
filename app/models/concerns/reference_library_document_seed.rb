module ReferenceLibraryDocumentSeed
  extend ActiveSupport::Concern

  module ClassMethods
    def seed!
      warn "Seeding data for ReferenceLibraryDocuments..."
      seed_path = "data/reference_library_documents_from_airtable.json"
      doc_attrs = JSON.parse Rails.root.join(seed_path).read
      ReferenceLibraryDocument.insert_all!(doc_attrs).count
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
