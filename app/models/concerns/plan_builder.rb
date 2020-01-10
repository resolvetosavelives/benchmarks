module PlanBuilder
  extend ActiveSupport::Concern

  # these are stored in memory and are not persisted to the database
  attr_accessor :assessment_technical_areas, :assessment_indicators

  # this method is in this module because it deals with assessment_indicator which
  # are populated in this module before the Plan is persisted.
  def score_value_for(assessment_indicator:)
    assessment.scores.detect do |score|
      score.assessment_indicator.id.eql?(assessment_indicator.id)
    end&.value
  end

  # this method is in this module because it deals with assessment_indicator which
  # are populated in this module before the Plan is persisted.
  def calculate_goal_value_for(assessment_indicator:)
    score = score_value_for(assessment_indicator: assessment_indicator)
    if is_5_year_plan
      if score <= 3
        4
      else
        5
      end
    elsif score.eql?(5)
      score
    else
      score + 1
    end
  end

  module ClassMethods
    def new_from_assessment(assessment:, is_5_year_plan: false, technical_area_ids: nil)
      plan = Plan.new(
        assessment: assessment,
        name: "#{assessment.country.name} draft plan",
        is_5_year_plan: is_5_year_plan
      )
      assessment_publication = assessment.assessment_publication
      assessment_technical_areas = if technical_area_ids.present? && technical_area_ids.any?
        assessment_publication.assessment_technical_areas.where(id: technical_area_ids).all
      else
        assessment_publication.assessment_technical_areas
      end
      assessment_indicators = assessment_technical_areas.map(&:assessment_indicators)
      plan.assessment_technical_areas = assessment_technical_areas
      plan.assessment_indicators = assessment_indicators
      plan
    end

    ##
    # +indicator_attrs+ will be, for example: {
    #   "jee1_ind_p11"=>"1",
    #   "jee1_ind_p11_goal"=>"2",
    #   "jee1_ind_p12"=>"1",
    #   "jee1_ind_p12_goal"=>"2",
    #   ...
    # }
    # For JEE1, there are 48 of these score/goal pairs.
    ##
    # TODO: no test coverage yet. Cases to test for should include..
    #  - duplicated benchmark_indicator.ids in plan_benchmark_indicators
    #  - duplicate activities
    #  - make sure activities include multiple benchmark_indicator_activities.levels when appro
    #  - assessment_indicator maps to multiple benchmark_indicators
    #  - benchmark_indicator maps to multiple assessment_indicators (yes both happen)
    #  - activity sequence is scoped to benchmark_indicator_id even with differing goal levels, see +plan_activity_sequence+ below
    def create_from_goal_form(indicator_attrs:, assessment:, plan_name:, user: nil)
      num_of_underscores = assessment.spar_2018? ? 3 : 2
      named_ids = indicator_attrs.select { |k, _| k.count("_").eql?(num_of_underscores) }.keys
      scores_and_goals_by_named_id = {}
      named_ids.each do |named_id|
        scores_and_goals_by_named_id[named_id] = {
          score: indicator_attrs[named_id].to_i,
          goal:  indicator_attrs[named_id + "_goal"].to_i,
        }
      end
      plan = Plan.new({
        name: plan_name,
        assessment: assessment,
        user: user,
      })
      plan_goals = []
      plan_activities = []
      assessment_indicators = AssessmentIndicator.where(named_id: named_ids).all.uniq

      # NB: Since Activities are an ordered list, we use +plan_activity_sequence+
      # to store a 1-based index of the sequence of each plan_activity within the
      # scope of each unique benchmark_indicator. There are cases where the same
      # benchmark_indicator will appear twice but with different score levels
      # because of how indicators are crosswalked. So this handles that complexity
      # to ensure that even across multiple score levels, activities' sequences
      # are scoped to a benchmark_indicator_id. For example, when this is NOT
      # working properly, you will see benchmark_indicator(id:4,goal:3) having a
      # sequence of 1 - 5, and the same benchmark_indicator(id:4,goal:4:4) but
      # having a different goal level having a sequence of 1 - 4. Correct
      # functionality would be that all 9 activities for benchmark_indicator(id:4)
      # having sequence of 1 - 9.
      plan_activity_sequence = 0

      assessment_indicators.each do |assessment_indicator|
        score_and_goal = scores_and_goals_by_named_id[assessment_indicator.named_id]
        goal_value = score_and_goal[:goal]
        benchmark_indicators = assessment_indicator.benchmark_indicators.uniq
        benchmark_indicators.each do |benchmark_indicator|
          already_seen_indicator = plan_goals.any? { |pbi|
            pbi.benchmark_indicator.id.eql?(benchmark_indicator.id)
          }
          unless already_seen_indicator
            plan_goals << PlanGoal.new(
              plan: plan,
              assessment_indicator: assessment_indicator,
              benchmark_indicator: benchmark_indicator,
              value: goal_value
            )
            # reset the activity sequence for each unique benchmark_indicator
            plan_activity_sequence = 0
          end
          bia = benchmark_indicator.activities
            .where("level > :score AND level <= :goal", score_and_goal)
            .order(:sequence)
            .all
          bia.each do |benchmark_indicator_activity|
            unless plan_activities.any? { |pa| pa.benchmark_indicator_activity.id.eql?(benchmark_indicator_activity.id) }
              plan_activity_sequence += 1
              plan_activities << PlanActivity.new(
                plan: plan,
                benchmark_indicator_activity: benchmark_indicator_activity,
                benchmark_indicator: benchmark_indicator,
                sequence: plan_activity_sequence,
              )
            end
          end
        end
        Plan.transaction do
          plan.goals = plan_goals
          plan.plan_activities = plan_activities
          plan.save!
        end
      end
      plan
    end
  end
end
