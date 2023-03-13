# frozen_string_literal: true

class ReferenceLibraryDocumentsController < ApplicationController
  def download
    document =
      ReferenceLibraryDocument.find(params[:reference_library_document_id])

    unless document.download_url
      return(
        redirect_to reference_library_path,
                    notice: "Failed to load document, please try again."
      )
    end

    redirect_to document.download_url, allow_other_host: true
  end
end
