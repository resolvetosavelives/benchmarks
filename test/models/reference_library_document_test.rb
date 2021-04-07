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

  describe ".all_from_csv" do
    let(:csv_data) { CSV.read(ReferenceLibraryDocument::PATH_TO_CSV_FILE) }
    let(:result) { ReferenceLibraryDocument.all_from_csv }

    it "returns an array of ReferenceLibraryDocuments" do
      _(result).must_be_instance_of Array
      _(result.size).must_equal(csv_data.size - 1)
      _(result.first).must_be_instance_of ReferenceLibraryDocument
      _(result.last).must_be_instance_of ReferenceLibraryDocument
    end
  end

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

    let(:result) { ReferenceLibraryDocument.new_from_csv_row(row) }

    before do
      ReferenceLibraryDocument
        .expects(:extract_download_url)
        .at_least_once
        .with("CSV download URL")
        .returns("test download URL")
      ReferenceLibraryDocument
        .stubs(:extract_download_url)
        .at_least_once
        .with("CSV thumbnail URL")
        .returns("test thumbnail URL")
    end

    it "returns an instance of ReferenceLibraryDocument with its members set" do
      _(result).must_be_instance_of ReferenceLibraryDocument
      _(result.title).must_equal "title xyz"
      _(result.description).must_equal "desc xyz"
      _(result.author).must_equal "author xyz"
      _(result.date).must_equal "date xyz"
      _(result.relevant_pages).must_equal "page xyz"
      _(result.download_url).must_equal "test download URL"
      _(result.thumbnail_url).must_equal "test thumbnail URL"
      _(result.technical_area).must_equal "Antimicrobial Resistance"
      _(result.reference_type).must_equal "Case Study"
    end

    it "won't recreate rows with identical download urls" do
      _(result.save).must_equal true
      _(ReferenceLibraryDocument.new_from_csv_row(row).save).must_equal false
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
