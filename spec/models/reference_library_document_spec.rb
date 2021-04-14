require(File.expand_path("./test/test_helper"))
require("minitest/spec")
require("minitest/autorun")
describe(ReferenceLibraryDocument) do
  let(:document) { build(:reference_library_document) }
  it("can be created") { document.save! }
  describe(".reference_type_ordinal") do
    describe("for a known type") do
      it("returns the expected integer") do
        _(ReferenceLibraryDocument.reference_type_ordinal("Briefing Note"))
          .must_equal(1)
        _(ReferenceLibraryDocument.reference_type_ordinal("Case Study"))
          .must_equal(2)
        _(ReferenceLibraryDocument.reference_type_ordinal("Training Package"))
          .must_equal(8)
      end
    end
    describe("for nil") do
      it("returns nil") do
        _(ReferenceLibraryDocument.reference_type_ordinal(nil)).must_be_nil
      end
    end
    describe("for an invalid type") do
      it("returns nil") do
        _(ReferenceLibraryDocument.reference_type_ordinal("Something Else"))
          .must_be_nil
        _(ReferenceLibraryDocument.reference_type_ordinal("Briefing Notes"))
          .must_be_nil
      end
    end
  end
  describe(".reference_type_scope_name") do
    let(:type) { "Cat Video" }
    let(:scope_name) { :cat_videos }
    it("symbolizes, pluralizes, parameterizes reference type string") do
      _(ReferenceLibraryDocument.reference_type_scope_name(type)).must_equal(
        scope_name
      )
    end
  end
end
