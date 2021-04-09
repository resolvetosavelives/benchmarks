class AddLastModifiedToReferenceLibraryDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :reference_library_documents, :last_modified, :timestamp
  end
end
