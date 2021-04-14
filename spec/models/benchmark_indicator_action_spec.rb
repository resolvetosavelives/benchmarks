require(File.expand_path("./test/test_helper"))
require("minitest/spec")
require("minitest/autorun")
describe(BenchmarkIndicatorAction) do
  let(:bia) { build(:benchmark_indicator_action) }
  it("can be created") { bia.save! }
  describe("#documents_by_type") do
    let(:doc) { ReferenceLibraryDocument.new(reference_type: "Tool") }
    let(:results) { { tools: ([doc]) } }
    before { (bia.reference_library_documents << doc) }
    it("responds with a hash of documents sorted by reference type") do
      _(bia.documents_by_type).must_equal(results)
    end
  end
end
