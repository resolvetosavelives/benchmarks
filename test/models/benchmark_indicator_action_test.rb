require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe BenchmarkIndicatorAction do
  let(:bia) { BenchmarkIndicatorAction.new(params) }
  let(:params) do
    {
      benchmark_indicator_id: 1,
      text: "Give cats the vote.",
      level: 4,
      sequence: 1,
      action_types: [7]
    }
  end

  describe "#documents_by_type" do
    let(:doc) { ReferenceLibraryDocument.new(reference_type: "Tool") }
    let(:results) { { tools: [doc] } }

    before { bia.reference_library_documents << doc }

    it "responds with a hash of documents sorted by reference type" do
      _(bia.documents_by_type).must_equal results
    end
  end
end
