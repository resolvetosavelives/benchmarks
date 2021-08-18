# frozen_string_literal: true

require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe ReferenceLibraryDocument do
  let(:document) { build(:reference_library_document) }

  it "can be created" do
    document.save!
  end

  describe ".reference_type_ordinal" do
    describe "for a known type" do
      it "returns the expected integer" do
        _(
          ReferenceLibraryDocument.reference_type_ordinal("Best Practices")
        ).must_equal 1
        _(
          ReferenceLibraryDocument.reference_type_ordinal("Guidelines")
        ).must_equal 2
        _(ReferenceLibraryDocument.reference_type_ordinal("Tools")).must_equal 3
        _(
          ReferenceLibraryDocument.reference_type_ordinal("Training Packages")
        ).must_equal 4
      end
    end

    describe "for nil" do
      it "returns nil" do
        _(ReferenceLibraryDocument.reference_type_ordinal(nil)).must_be_nil
      end
    end

    describe "for an invalid type" do
      it "returns nil" do
        _(ReferenceLibraryDocument.reference_type_ordinal("Something Else"))
          .must_be_nil
        _(ReferenceLibraryDocument.reference_type_ordinal("Guideline"))
          .must_be_nil
      end
    end
  end

  describe ".distinct_types" do
    describe "when there are zero documents" do
      before { ReferenceLibraryDocument.destroy_all }

      it "returns empty array" do
        _(ReferenceLibraryDocument.distinct_types).must_equal []
      end
    end

    describe "when there are some documents" do
      it "returns an array of the expected strings" do
        _(ReferenceLibraryDocument.distinct_types).must_equal [
                                                                "Best Practices",
                                                                "Guidelines",
                                                                "Tools",
                                                                "Training Packages"
                                                              ]
      end
    end
  end
end
