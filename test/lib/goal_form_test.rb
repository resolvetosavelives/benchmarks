require 'test_helper'

class GoalFormTest < ActiveSupport::TestCase
  def setup
    @crosswalk = JSON.load File.open './app/fixtures/crosswalk.json'
    @benchmarks = BenchmarksFixture.new
  end

  test 'a simple draft plan' do
    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'jee1',
                                      'jee1_ind_p11' => 1,
                                      'jee1_ind_p11_goal' => 3
                                    }.with_indifferent_access
                                  ),
                                  @crosswalk,
                                  @benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map],
                 {
                   '1.1' =>
                     @benchmarks.goal_activities(
                       '1.1',
                       (Score.new 1),
                       (Score.new 3)
                     )
                 }
    assert_equal 3, plan[:goals]['1.1']['value']
  end

  test 'it gets no activities if the score is already a 5' do
    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'jee1',
                                      'jee1_ind_p11' => 5,
                                      'jee1_ind_p11_goal' => 5
                                    }.with_indifferent_access
                                  ),
                                  @crosswalk,
                                  @benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map], { '1.1' => [] }
    assert_equal 5, plan[:goals]['1.1']['value']
  end

  test 'it gets all of the activities in a range with multiple mappings' do
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
                                  @crosswalk,
                                  @benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map],
                 {
                   '1.1' =>
                     @benchmarks.goal_activities(
                       '1.1',
                       (Score.new 1),
                       (Score.new 5)
                     )
                 }
    assert_equal 5, plan[:goals]['1.1']['value']
  end

  test 'it gets all of the activities in a range with a gap between multiple mappings' do
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
                                  @crosswalk,
                                  @benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'jee1'
    assert_equal plan[:activity_map],
                 {
                   '1.1' =>
                     @benchmarks.goal_activities(
                       '1.1',
                       (Score.new 1),
                       (Score.new 4)
                     )
                 }
    assert_equal 4, plan[:goals]['1.1']['value']
  end

  test 'it gets proper results from a SPAR score' do
    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'spar_2018',
                                      'spar_2018_ind_c11' => 1,
                                      'spar_2018_ind_c11_goal' => 2
                                    }.with_indifferent_access
                                  ),
                                  @crosswalk,
                                  @benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'spar_2018'
    assert_equal plan[:activity_map],
                 {
                   '1.1' =>
                     @benchmarks.goal_activities(
                       '1.1',
                       (Score.new 1),
                       (Score.new 2)
                     )
                 }
    assert_equal 2, plan[:goals]['1.1']['value']
  end

  test 'it gets proper results with a starting SPAR score of 0' do
    plan =
      GoalForm.create_draft_plan! (
                                    {
                                      'country' => 'Australia',
                                      'assessment_type' => 'spar_2018',
                                      'spar_2018_ind_c11' => 0,
                                      'spar_2018_ind_c11_goal' => 2
                                    }.with_indifferent_access
                                  ),
                                  @crosswalk,
                                  @benchmarks

    assert_equal plan[:name], 'Australia draft plan'
    assert_equal plan[:country], 'Australia'
    assert_equal plan[:assessment_type], 'spar_2018'
    assert_equal plan[:activity_map],
                 {
                   '1.1' =>
                     @benchmarks.goal_activities(
                       '1.1',
                       (Score.new 1),
                       (Score.new 2)
                     )
                 }
    assert_equal 2, plan[:goals]['1.1']['value']
  end
end
