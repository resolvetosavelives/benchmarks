require File.expand_path('./test/test_helper')
require "minitest/spec"
require "minitest/autorun"

describe Plan do

  describe "#count_activities_by_ta" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns an array" do
      expected = [6, 12, 19, 9, 11, 13, 19, 7, 15, 18, 11, 15, 7, 19, 20, 16, 14, 4]
      plan.count_activities_by_ta.must_equal expected
    end
  end

  describe "#indicator_for" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns the expected plan_benchmark_indicator" do
      expected_pbi = plan.plan_benchmark_indicators.detect do |pbi|
        pbi.benchmark_indicator.display_abbreviation.eql?("2.1")
      end
      expected_pbi.wont_be_nil

      plan.indicator_for(expected_pbi.benchmark_indicator).must_equal expected_pbi
    end
  end

  describe "#indicator_score_goal_for" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns the expected plan_benchmark_indicator, score, and goal" do
      expected_pbi = plan.plan_benchmark_indicators.detect do |pbi|
        pbi.benchmark_indicator.display_abbreviation.eql?("2.1")
      end
      expected_pbi.wont_be_nil

      plan.indicator_score_goal_for(expected_pbi.benchmark_indicator).must_equal [expected_pbi, 2, 3]
    end
  end

  describe "#activities_for" do
    let(:plan) { create(:plan_nigeria_jee1) }

    it "returns the expected plan_benchmark_indicator, score, and goal" do
      expected_pbi = plan.plan_benchmark_indicators.detect do |pbi|
        pbi.benchmark_indicator.display_abbreviation.eql?("2.1")
      end
      expected_pbi.wont_be_nil

      result = plan.activities_for(expected_pbi.benchmark_indicator)
      result.must_be_instance_of Array
      result.first.must_be_instance_of PlanActivity
      result.size.must_equal 9
    end
  end

end
