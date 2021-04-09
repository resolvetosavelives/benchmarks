class AddUrlToReferenceLibraryDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :reference_library_documents, :url, :string
  end
end
