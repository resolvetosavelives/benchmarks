# frozen_string_literal: true

class PagesController < ApplicationController
  def reference_library
    @technical_areas = BenchmarkTechnicalArea.all
    @ref_doc_types = ReferenceLibraryDocument.distinct_types

    page = reference_library_params[:page]
    technical_area = reference_library_params[:technical_area]
    reference_types = reference_library_params[:reference_types]
    @documents = ReferenceLibraryDocument.order(:id).page(page)
    @documents =
      @documents.where(
        "? = ANY(technical_areas)",
        technical_area
      ) if technical_area.present?
    @documents =
      @documents.where(reference_type: reference_types) if reference_types
      .present?
  end

  private

  def reference_library_params
    params
      .permit(:page, :technical_area, reference_types: [])
      .with_defaults(page: 1)
  end
end
