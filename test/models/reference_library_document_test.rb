# frozen_string_literal: true

require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"
require "csv"

describe ReferenceLibraryDocument do
  describe "#extract_download_url" do
    let(:attachment_field) do
      "One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso (FRENCH).pdf (https://dl.airtable.com/.attachments/d273fbb3427d94635ddb734a14f95e26/98c1a677/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFasoFRENCH.pdf),One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso.pdf (https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf)"
    end

    it "returns the expected URL" do
      _(
        ReferenceLibraryDocument.extract_download_url(attachment_field)
      ).must_equal "https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf"
    end
  end

  # describe ".import!" do
  #   let(:csv_filename) do
  #     "test/fixtures/files/reference_library_documents_test.csv"
  #   end
  #   let(:result) { ReferenceLibraryDocument.all }
  #   before { ReferenceLibraryDocument.import!(csv_filename) }

  #   it "returns the expected set of ReferenceLibraryDocuments" do
  #     _(result.size).must_equal(1)
  #     _(result.first.title).must_equal(
  #       "Establishment of a Sentinel Laboratory-Based Antimicrobial Resistance Surveillance Network in Ethiopia"
  #     )
  #     _(result.first.download_url).must_equal(
  #       "https://dl.airtable.com/.attachments/7db0812500c513bb055fe551030f0d84/b9d0e9bb/HazimEthiopiaAMRSurveillance.pdf"
  #     )
  #   end
  # end

  describe "#new_from_csv_row" do
    let(:row) do
      [
        nil,
        "CSV download URL", #1
        "title xyz", #2
        "desc xyz", #3
        "Antimicrobial Resistance", #4
        nil, #5
        "Case Study", #6
        "author xyz", #7
        "date xyz", #8
        nil,
        nil,
        "page xyz", #11
        nil,
        "CSV thumbnail URL" #13
      ]
    end

    let(:result) { ReferenceLibraryDocument.record_hash_from_row(row) }

    let(:expected_hash) do
      {
        title: "title xyz",
        description: "desc xyz",
        author: "author xyz",
        date: "date xyz",
        relevant_pages: "page xyz",
        download_url: "test download URL",
        thumbnail_url: "test thumbnail URL",
        technical_area: "Antimicrobial Resistance",
        reference_type: "Case Study"
      }
    end

    before do
      ReferenceLibraryDocument
        .expects(:extract_download_url)
        .with("CSV download URL")
        .returns("test download URL")
      ReferenceLibraryDocument
        .stubs(:extract_download_url)
        .with("CSV thumbnail URL")
        .returns("test thumbnail URL")
    end

    it "returns a hash with the expected keys and values" do
      _(result).must_equal expected_hash
    end
  end

  describe ".reference_type_ordinal" do
    describe "for a known type" do
      it "returns the expected integer" do
        _(
          ReferenceLibraryDocument.reference_type_ordinal("Briefing Note")
        ).must_equal 1
        _(
          ReferenceLibraryDocument.reference_type_ordinal("Case Study")
        ).must_equal 2
        _(
          ReferenceLibraryDocument.reference_type_ordinal("Training Package")
        ).must_equal 8
      end
    end

    describe "for nil" do
      it "returns nil" do
        _(ReferenceLibraryDocument.reference_type_ordinal(nil)).must_be_nil
      end
    end

    describe "for an invalid type" do
      it "returns nil" do
        ReferenceLibraryDocument.reference_type_ordinal("Something Else")
          .must_be_nil
        ReferenceLibraryDocument.reference_type_ordinal("Briefing Notes")
          .must_be_nil
      end
    end
  end
end
