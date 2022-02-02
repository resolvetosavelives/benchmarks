require "rails_helper"

RSpec.describe(BenchmarkIndicatorAction) do
  let(:bia) { build(:benchmark_indicator_action) }

  it "can be created" do
    bia.save!
  end

  describe "#documents_by_type" do
    let(:doc) { ReferenceLibraryDocument.new(reference_type: "Tool") }
    let(:results) { { tools: [doc] } }

    before { bia.reference_library_documents << doc }

    it "responds with a hash of documents sorted by reference type" do
      expect(bia.documents_by_type).to eq(results)
    end
  end
end
