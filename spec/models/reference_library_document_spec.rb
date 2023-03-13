require "rails_helper"

RSpec.describe ReferenceLibraryDocument, type: :model do
  let(:document) { build(:reference_library_document) }

  it("can be created") { document.save! }

  describe ".reference_type_ordinal" do
    describe "for a known type" do
      it "returns the expected integer" do
        expect(
          ReferenceLibraryDocument.reference_type_ordinal("Best Practice")
        ).to eq(1)
        expect(
          ReferenceLibraryDocument.reference_type_ordinal("Guideline")
        ).to eq(2)
        expect(ReferenceLibraryDocument.reference_type_ordinal("Tool")).to eq(3)
        expect(
          ReferenceLibraryDocument.reference_type_ordinal("Training Package")
        ).to eq(4)
      end
    end

    describe "for nil" do
      it "returns nil" do
        expect(ReferenceLibraryDocument.reference_type_ordinal(nil)).to be_nil
      end
    end

    describe "for an invalid type" do
      it "returns nil" do
        expect(
          ReferenceLibraryDocument.reference_type_ordinal("Something Else")
        ).to be_nil
      end
    end
  end

  describe ".distinct_types" do
    describe "when there are zero documents" do
      before { ReferenceLibraryDocument.destroy_all }

      it "returns empty array" do
        expect(ReferenceLibraryDocument.distinct_types).to eq([])
      end
    end

    describe "when there are some documents" do
      it "returns an array of the expected strings" do
        expect(ReferenceLibraryDocument.distinct_types).to eq(
          ["Best Practice", "Guideline", "Tool", "Training Package"]
        )
      end
    end
  end

  describe "#download_url" do
    let(:document) { create(:reference_library_document) }
    let(:attachment_url) { "https://example.com/path/to/file.pdf" }

    before do
      allow(Airtable::ReferenceLibraryDocument).to receive(:find).and_return(
        Airtable::ReferenceLibraryDocument.new(
          "Attachments" => [{ "url" => attachment_url }]
        )
      )
    end

    it "loads attachment url from airtable" do
      expect(document.download_url).to eq(attachment_url)
    end
  end
end
