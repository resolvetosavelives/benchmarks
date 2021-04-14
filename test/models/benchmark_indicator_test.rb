require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe BenchmarkIndicator do
  it "can be created" do
    build(:benchmark_indicator).save!
  end
end
