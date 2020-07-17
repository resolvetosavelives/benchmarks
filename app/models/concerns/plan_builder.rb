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
    if is_5_year?
      score <= 3 ? 4 : 5
    elsif score.eql?(5)
      score
    else
      score + 1
    end
  end

  module ClassMethods
    def new_from_assessment(
      assessment:, is_5_year_plan: false, technical_area_ids: nil
    )
      plan_term =
        is_5_year_plan ? Plan::TERM_TYPES.second : Plan::TERM_TYPES.first
      plan =
        Plan.new(
          assessment: assessment,
          name: "#{assessment.country.name} draft plan",
          term: plan_term,
        )
      assessment_publication = assessment.assessment_publication
      assessment_technical_areas =
        if technical_area_ids.present? && technical_area_ids.any?
          assessment_publication.assessment_technical_areas.includes(
            :assessment_indicators,
          ).where(id: technical_area_ids).all
        else
          assessment_publication.assessment_technical_areas.includes(
            :assessment_indicators,
          )
        end
      assessment_indicators =
        assessment_technical_areas.map(&:assessment_indicators)
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
    #  - duplicate actions
    #  - make sure actions include multiple benchmark_indicator_actions.levels when appro
    #  - assessment_indicator maps to multiple benchmark_indicators
    #  - benchmark_indicator maps to multiple assessment_indicators (yes both happen)
    def create_from_goal_form(
      indicator_attrs:,
      assessment:,
      plan_name:,
      is_5_year_plan: false,
      disease_ids: [],
      user: nil
    )
      num_of_underscores = assessment.spar_2018? ? 3 : 2
      named_ids =
        indicator_attrs.select do |k, _|
          k.count("_").eql?(num_of_underscores)
        end.keys
      scores_and_goals_by_named_id = {}
      named_ids.each do |named_id|
        scores_and_goals_by_named_id[named_id] = {
          score: indicator_attrs[named_id].to_i,
          goal: indicator_attrs[named_id + "_goal"].to_i,
        }
      end
      plan_term =
        is_5_year_plan ? Plan::TERM_TYPES.second : Plan::TERM_TYPES.first
      plan =
        Plan.new(
          {
            name: plan_name, assessment: assessment, term: plan_term, user: user
          },
        )
      # fetch disease-specific actions for all of the selected IDs in one query
      disease_actions = BenchmarkIndicatorAction.where(disease_id: disease_ids).all
      # build a "disease-action" map of benchmarkIndicatorID => Action so that it can be used in the loop of BenchmarkIndicators
      disease_action_map = disease_actions.reduce({}) do |acc, action|
        if acc[action.benchmark_indicator_id.to_s].nil?
          acc[action.benchmark_indicator_id.to_s] = []
        end
        acc[action.benchmark_indicator_id.to_s] << action
        acc
      end
      plan_goals = []
      plan_actions = []
      assessment_indicators =
        AssessmentIndicator.includes(
          { benchmark_indicators: :benchmark_technical_area },
        ).where(named_id: named_ids).distinct.all
      assessment_indicators.each do |assessment_indicator|
        score_and_goal =
          scores_and_goals_by_named_id[assessment_indicator.named_id]
        goal_value = score_and_goal[:goal]
        benchmark_indicators = assessment_indicator.benchmark_indicators.uniq
        benchmark_indicators.each do |benchmark_indicator|
          already_seen_indicator =
            plan_goals.any? do |pbi|
              pbi.benchmark_indicator.id.eql?(benchmark_indicator.id)
            end
          unless already_seen_indicator
            plan_goals <<
              PlanGoal.new(
                plan: plan,
                assessment_indicator: assessment_indicator,
                benchmark_indicator: benchmark_indicator,
                value: goal_value,
              )
          end
          bia =
            benchmark_indicator.actions.where(
              "level > :score AND level <= :goal",
              score_and_goal,
            ).order(:sequence).all
          # use disease_action_map to append its Action(s) to the matching Indicator when the disease-specific action.benchmark_indicator_id
          #   matches the current benchmark_indicator.id
          disease_actions_for_indicator = disease_action_map[benchmark_indicator.id.to_s]
          if disease_actions_for_indicator.present?
            bia += disease_actions_for_indicator
          end
          bia.each do |benchmark_indicator_action|
            unless plan_actions.any? do |pa|
                     pa.benchmark_indicator_action_id.eql?(
                       benchmark_indicator_action.id,
                     )
                   end
              plan_actions <<
                PlanAction.new(
                  plan: plan,
                  benchmark_indicator_action: benchmark_indicator_action,
                  benchmark_indicator: benchmark_indicator,
                  benchmark_technical_area:
                    benchmark_indicator.benchmark_technical_area,
                )
            end
          end
        end
      end

      begin
        plan.disease_ids = disease_ids
      rescue ActiveRecord::RecordNotFound =>  e
        raise Exceptions::InvalidDiseasesError
      end

      Plan.transaction do
        plan.goals = plan_goals
        plan.plan_actions = plan_actions
        plan.save!
      end
      plan
    end
  end
end
