require 'test_helper'

class GoalFormTest < ActiveSupport::TestCase
  test 'a simple draft plan' do
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'jee1',
                                      'jee1_ind_p11' => 1,
                                      'jee1_ind_p11_goal' => 3
                                    }.with_indifferent_access
                                  ),
                                  crosswalk,
                                  benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map],
                 { '1.1' => benchmarks.activities('1.1', score: 1, goal: 3) }
  end

  test 'it gets no activities if the score is already a 5' do
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'jee1',
                                      'jee1_ind_p11' => 5,
                                      'jee1_ind_p11_goal' => 5
                                    }.with_indifferent_access
                                  ),
                                  crosswalk,
                                  benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map], { '1.1' => [] }
  end

  test 'it gets all of the activities in a range with multiple mappings' do
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'jee1',
                                      'jee1_ind_p11' => 1,
                                      'jee1_ind_p11_goal' => 3,
                                      'jee1_ind_p12' => 3,
                                      'jee1_ind_p12_goal' => 5
                                    }.with_indifferent_access
                                  ),
                                  crosswalk,
                                  benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map],
                 { '1.1' => benchmarks.activities('1.1', score: 1, goal: 5) }
  end

  test 'it gets all of the activities in a range with a gap between multiple mappings' do
    crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    benchmarks = BenchmarksFixture.new

    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'jee1',
                                      'jee1_ind_p11' => 1,
                                      'jee1_ind_p11_goal' => 2,
                                      'jee1_ind_p12' => 3,
                                      'jee1_ind_p12_goal' => 4
                                    }.with_indifferent_access
                                  ),
                                  crosswalk,
                                  benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map],
                 { '1.1' => benchmarks.activities('1.1', score: 1, goal: 4) }
  end
end
