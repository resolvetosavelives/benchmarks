require File.expand_path("./test/test_helper")
require "minitest/spec"
require "minitest/autorun"

describe PlanActivity do
  describe ".new_for_benchmark_activity" do
    it "returns a hash of the expected structure" do
      bia = BenchmarkIndicatorActivity.first
      bia.wont_be_nil
      bia.benchmark_indicator.wont_be_nil
      bia.benchmark_indicator.benchmark_technical_area.wont_be_nil
      result = PlanActivity.new_for_benchmark_activity bia

      result.must_be_instance_of PlanActivity
      result.benchmark_indicator_activity.wont_be_nil
      result.benchmark_indicator_activity.must_equal bia
      result.benchmark_indicator_id.wont_be_nil
      result.benchmark_indicator_id.must_equal bia.benchmark_indicator_id
      result.benchmark_technical_area_id.wont_be_nil
      result.benchmark_technical_area_id.must_equal bia.benchmark_technical_area_id
    end
  end
end
