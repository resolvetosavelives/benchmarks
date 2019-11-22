require File.expand_path('./test/test_helper')
require "minitest/spec"
require "minitest/autorun"

def demo_plan
  Plan.create! name: 'US Draft Plan',
               country: 'United States',
               assessment_type: 'jee2',
               activity_map: {
                 "2.1": [
                   {
                     'text' =>
                       'Designate or establish an NFP in line with the IHR requirements.',
                     'type_code_1' => 4,
                     'type_code_2' => nil,
                     'type_code_3' => nil
                   },
                   {
                     'text' =>
                       'Establish terms of reference outlining the role and responsibilities of IHR NFPs in fulfilling relevant obligations of the IHR.',
                     'type_code_1' => 10,
                     'type_code_2' => nil,
                     'type_code_3' => nil
                   },
                   {
                     'text' =>
                       "Maintain and regularly update a contact directory including all the members of NFP and capacitate NFPs for 24 hours a day, seven\n days a week (24/7) accessibility.",
                     'type_code_1' => 10,
                     'type_code_2' => 3,
                     'type_code_3' => nil
                   }
                 ],
                 "2.2": [
                   {
                     'text' =>
                       'Create/update the national action plan for improving health security and IHR capacity based on IHR monitoring and evaluation results.',
                     'type_code_1' => nil,
                     'type_code_2' => nil,
                     'type_code_3' => nil
                   }
                 ],
                 "3.3": [
                   {
                     'text' =>
                       'Use the national IPC assessment tool (IPCAT2) to identify precise areas still requiring action and update the plan of action.',
                     'type_code_1' => 2,
                     'type_code_2' => nil,
                     'type_code_3' => nil
                   }
                 ]
               },
               user_id: nil
end

describe Plan do
  before do
    @plan = demo_plan
  end

  describe "#activity_map" do

    describe "#capacities" do
      it "returns a sorted list of capacities" do
        assert_equal [2, 3], @plan.activity_map.capacities
      end
    end

    describe "#benchmarks" do
      it "returns a sorted list of benchmark ids in the plan" do
        @plan.activity_map.benchmarks.must_equal(
            [
                (BenchmarkId.from_s '2.1'),
                (BenchmarkId.from_s '2.2'),
                (BenchmarkId.from_s '3.3')
            ]
        )
      end
    end

    describe "#capacity_activities" do
      it "returns an indexed map of activities from a capacity id" do
        @plan.activity_map.capacity_activities(2).keys.must_equal %w[2.1 2.2]
      end
    end

    describe "#benchmark_activities" do
      it "returns a list of capacities from a BenchmarkId" do
        @plan.activity_map.benchmark_activities(
            BenchmarkId.from_s '2.1'
        ).size.must_equal 3
      end
    end

    describe "#capacity_benchmarks" do
      it "returns a list of benchmark ids within a given capacity" do
        @plan.activity_map.capacity_benchmarks(3)
            .must_equal [(BenchmarkId.from_s '3.3')]
        @plan.activity_map.capacity_benchmarks(2)
            .must_equal [(BenchmarkId.from_s '2.1'), (BenchmarkId.from_s '2.2')]
      end
    end

  end

  describe "#all_activities_for" do
    before do
      @plan_with_zero_activities = Plan.create!(
          name: 'US Draft Plan',
          country: 'United States',
          assessment_type: 'jee2',
          activity_map: {},
          user_id: nil
      )
      @plan_with_five_activities = demo_plan
    end

    it "returns the expected activities" do
      result = @plan_with_five_activities.all_activities

      result.size.must_equal 5
    end

    it "returns empty when a plan has no activities" do
      result = @plan_with_zero_activities.all_activities

      result.size.must_equal 0
    end

    it "returns empty when a plan has no activity_map" do
      plan = Plan.new
      result = plan.all_activities

      result.size.must_equal 0
    end
  end

  describe "#count_activities_by_capacity" do

    it "returns the expected array of integers" do
      @plan.count_activities_by_capacity.must_equal(
          [0, 4, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    end

  end

end
