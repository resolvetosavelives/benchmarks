# frozen_string_literal: true

class PagesController < ApplicationController
  def reference_library
    @technical_areas = BenchmarkTechnicalArea.all
    @documents = ReferenceLibraryDocument.all
    @ref_doc_types = ReferenceLibraryDocument.distinct_types
  end
end
