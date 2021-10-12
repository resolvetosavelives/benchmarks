class ChangeReferenceLibraryDocumentsToUseArray < ActiveRecord::Migration[6.1]
  def up
    add_column :reference_library_documents,
               :technical_areas,
               :string,
               array: true,
               default: []
    remove_column :reference_library_documents, :technical_area
  end

  def down
    remove_column :reference_library_documents, :technical_areas
    add_column :reference_library_documents,
               :technical_area,
               :string,
               array: true,
               default: []
  end
end
