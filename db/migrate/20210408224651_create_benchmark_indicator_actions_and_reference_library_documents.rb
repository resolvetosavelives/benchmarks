class CreateBenchmarkIndicatorActionsAndReferenceLibraryDocuments < ActiveRecord::Migration[
  6.1
]
  def change
    create_table :actions_and_documents, id: false do |t|
      t.belongs_to :benchmark_indicator_action
      t.belongs_to :reference_library_document
    end
  end
end
