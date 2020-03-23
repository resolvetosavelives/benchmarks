# frozen_string_literal: true

class PagesController < ApplicationController
  def reference_library
    @technical_areas = BenchmarkTechnicalArea.all
    @documents = ResourceLibraryDocument.all_from_csv
  end
end
