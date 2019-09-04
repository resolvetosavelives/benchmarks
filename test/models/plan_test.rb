require 'test_helper'

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

class PlanTest < ActiveSupport::TestCase
  test 'that I can get a sorted list of benchmark ids in the plan' do
    plan = demo_plan
    assert_equal [
                   (BenchmarkId.from_s '2.1'),
                   (BenchmarkId.from_s '2.2'),
                   (BenchmarkId.from_s '3.3')
                 ],
                 plan.activity_map.benchmarks
  end

  test 'that I can get a list of indicators given a capacity' do
    plan = demo_plan
    assert_equal [(BenchmarkId.from_s '3.3')], (plan.activity_map.indicators 3)
    assert_equal [(BenchmarkId.from_s '2.1'), (BenchmarkId.from_s '2.2')],
                 (plan.activity_map.indicators 2)
  end

  test 'that I can get a list of capacities from a BenchmarkId' do
    plan = demo_plan
    assert_equal 3,
                 (plan.activity_map.activities (BenchmarkId.from_s '2.1'))
                   .length
  end
end
