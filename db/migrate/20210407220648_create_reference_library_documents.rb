class CreateReferenceLibraryDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :reference_library_documents do |t|
      t.string :title
      t.string :description
      t.string :author
      t.string :date
      t.string :relevant_pages
      t.string :download_url
      t.string :thumbnail_url
      t.string :technical_area
      t.string :reference_type

      t.timestamps
    end
  end
end
