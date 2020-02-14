class PagesController < ApplicationController

  def resource_library
    @technical_areas = BenchmarkTechnicalArea.all
    @documents = ResourceLibraryDocument.all_from_csv
  end

end
