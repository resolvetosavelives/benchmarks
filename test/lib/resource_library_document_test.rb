require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"
require 'csv'

describe ResourceLibraryDocument do

  describe "#extract_download_url" do
    let(:attachment_field) { "One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso (FRENCH).pdf (https://dl.airtable.com/.attachments/d273fbb3427d94635ddb734a14f95e26/98c1a677/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFasoFRENCH.pdf),One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso.pdf (https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf)" }

    it "returns the expected URL" do
      (ResourceLibraryDocument.extract_download_url(attachment_field)).must_equal "https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf"
    end
  end

  describe ".all_from_csv" do
    let(:csv_data) { CSV.read(Rails.root.join("data", "resource_library_documents_from_airtable.csv")) }
    let(:result) { ResourceLibraryDocument.all_from_csv(csv_data) }

    it "returns an array of ResourceLibraryDocuments" do
      result.must_be_instance_of Array
      result.size.must_equal(csv_data.size - 1)
      result.first.must_be_instance_of ResourceLibraryDocument
      result.last.must_be_instance_of ResourceLibraryDocument
    end
  end

  describe "#new_from_csv" do
    let(:result) {
      ResourceLibraryDocument.new_from_csv(
        "title xyz", "desc xyz", "author xyz", "date xyz", "page xyz", "CSV download URL", "CSV thumbnail URL") }
    before do
      ResourceLibraryDocument.expects(:extract_download_url).with("CSV download URL").returns("test download URL")
      ResourceLibraryDocument.stubs(:extract_download_url).with("CSV thumbnail URL").returns("test thumbnail URL")
    end

    it "returns an instance of ResourceLibraryDocument with its members set" do
      result.must_be_instance_of ResourceLibraryDocument
      result.title.must_equal "title xyz"
      result.description.must_equal "desc xyz"
      result.author.must_equal "author xyz"
      result.date.must_equal "date xyz"
      result.relevant_pages.must_equal "page xyz"
      result.download_url.must_equal "test download URL"
      result.thumbnail_url.must_equal "test thumbnail URL"
    end
  end

end
