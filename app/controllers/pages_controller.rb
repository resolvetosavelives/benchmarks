class PagesController < ApplicationController

  def resource_library
    @technical_areas = BenchmarkTechnicalArea.all
    @documents = ResourceLibraryDocument.all_from_csv Rails.root.join("data", "resource_library_documents_from_airtable.csv")
  end

end
