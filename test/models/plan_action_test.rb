require File.expand_path('./test/test_helper')
require 'minitest/spec'
require 'minitest/autorun'

describe PlanAction do
  describe '.new_for_benchmark_action' do
    it 'returns a hash of the expected structure' do
      bia = BenchmarkIndicatorAction.first
      bia.wont_be_nil
      bia.benchmark_indicator.wont_be_nil
      bia.benchmark_indicator.benchmark_technical_area.wont_be_nil
      result = PlanAction.new_for_benchmark_action bia

      _(result).must_be_instance_of PlanAction
      result.benchmark_indicator_action.wont_be_nil
      _(result.benchmark_indicator_action).must_equal bia
      result.benchmark_indicator_id.wont_be_nil
      _(result.benchmark_indicator_id).must_equal bia.benchmark_indicator_id
      result.benchmark_technical_area_id.wont_be_nil
      _(result.benchmark_technical_area_id).must_equal bia
                                                         .benchmark_technical_area_id
    end
  end
end
