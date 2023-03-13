# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReferenceLibraryDocuments", type: :request do
  describe "GET /reference_library_documents/:reference_library_document_id/download" do
    let(:reference_library_document) { create(:reference_library_document) }
    let(:document_url) { "https://example.com/path/to/document.pdf" }

    before do
      allow_any_instance_of(ReferenceLibraryDocument).to receive(:download_url)
        .and_return(document_url)
    end

    it "redirects to download url of document" do
      get reference_library_document_download_url(reference_library_document)
      expect(response).to redirect_to(document_url)
    end

    it "redirects back to reference library if download_url failed to load" do
      allow_any_instance_of(ReferenceLibraryDocument).to receive(:download_url)
        .and_return(nil)

      get reference_library_document_download_url(reference_library_document)
      expect(response).to redirect_to(reference_library_path)
      expect(response.request.flash[:notice]).to eq(
        "Failed to load document, please try again."
      )
    end
  end
end
