class RunUpdateDocumentsTask < ActiveRecord::Migration[7.0]
  def up
    Rake::Task["update:reference_documents"].invoke
  end
end
