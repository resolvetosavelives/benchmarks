require "test_helper"

describe ActionDocument do
  it "can be created" do
    ActionDocument.create!(
      benchmark_indicator_action: build(:benchmark_indicator_action),
      reference_library_document: build(:reference_library_document)
    )
  end
end
