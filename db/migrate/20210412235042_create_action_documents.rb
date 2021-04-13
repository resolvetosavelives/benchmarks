class CreateActionDocuments < ActiveRecord::Migration[6.1]
  def up
    create_table :action_documents do |t|
      t.belongs_to :benchmark_indicator_action, null: false, foreign_key: true
      t.belongs_to :reference_library_document, null: false, foreign_key: true

      t.timestamps
    end
    drop_table :actions_and_documents
  end

  def down
    drop_table :action_documents
    create_table :actions_and_documents, id: false do |t|
      t.belongs_to :benchmark_indicator_action
      t.belongs_to :reference_library_document
    end
  end
end
