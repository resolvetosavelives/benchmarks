class RemoveDocumentUrlFromReferenceLibraryDocuments < ActiveRecord::Migration[
  7.0
]
  def change
    remove_column :reference_library_documents, :download_url
    add_column :reference_library_documents, :airtable_id, :string
  end
end
