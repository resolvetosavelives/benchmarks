module PlanBuilder
  extend ActiveSupport::Concern

  # these are stored in memory and are not persisted to the database
  attr_accessor :assessment_technical_areas, :assessment_indicators

  # this method is in this module because it deals with assessment_indicator which
  # are populated in this module before the Plan is persisted.
  def score_value_for(assessment_indicator:)
    assessment.scores.find_by(assessment_indicator: assessment_indicator)&.value
  end

  # this method is in this module because it deals with assessment_indicator which
  # are populated in this module before the Plan is persisted.
  def calculate_goal_value_for(assessment_indicator:)
    score = score_value_for(assessment_indicator: assessment_indicator) || 0
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
      assessment:,
      is_5_year_plan: false,
      technical_area_ids: nil
    )
      plan_term =
        is_5_year_plan ? Plan::TERM_TYPES.second : Plan::TERM_TYPES.first
      plan =
        Plan.new(
          assessment: assessment,
          name: "#{assessment.country.name} draft plan",
          term: plan_term
        )
      assessment_publication = assessment.assessment_publication
      assessment_technical_areas =
        if technical_area_ids.present? && technical_area_ids.any?
          assessment_publication
            .assessment_technical_areas
            .includes(:assessment_indicators)
            .where(id: technical_area_ids)
            .all
        else
          assessment_publication.assessment_technical_areas.includes(
            :assessment_indicators
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
      named_ids = create_named_ids(assessment, indicator_attrs)
      scores_and_goals_by_named_id =
        create_scores_and_goals(named_ids, indicator_attrs)
      plan_term =
        is_5_year_plan ? Plan::TERM_TYPES.second : Plan::TERM_TYPES.first

      plan =
        Plan.new(
          name: plan_name,
          assessment: assessment,
          term: plan_term,
          user: user
        )

      BenchmarkIndicator.find_each do |bi|
        ai =
          bi.assessment_indicators.min_by do |ai|
            scores_and_goals_by_named_id.dig(ai.named_id, :score) || 1_000
          end

        goal = scores_and_goals_by_named_id.dig(ai.named_id, :goal)
        score = scores_and_goals_by_named_id.dig(ai.named_id, :score)

        plan.goals.build(
          assessment_indicator: ai,
          benchmark_indicator: bi,
          # assessed_value: score, # oops I didn't create a migration for this
          value: goal
        )

        bi
          .actions_for(score: score, goal: goal)
          .each do |action|
            plan.plan_actions.build(
              benchmark_indicator: bi,
              benchmark_indicator_action: action,
              benchmark_technical_area: bi.benchmark_technical_area
            )
          end
      end

      begin
        plan.disease_ids = disease_ids
      rescue ActiveRecord::RecordNotFound => e
        raise Exceptions::InvalidDiseasesError
      end

      Plan.transaction { plan.save! }

      plan
    end

    def create_named_ids(assessment, indicator_attrs)
      num_of_underscores = assessment.spar_2018? ? 3 : 2
      indicator_attrs.select do |k, _|
        k.count("_").eql?(num_of_underscores)
      end.keys
    end

    def create_scores_and_goals(named_ids, indicator_attrs)
      scores_and_goals_by_named_id = {}
      named_ids.each do |named_id|
        scores_and_goals_by_named_id[named_id] = {
          score: indicator_attrs[named_id].to_i,
          goal: indicator_attrs[named_id + "_goal"].to_i
        }
      end
      scores_and_goals_by_named_id
    end
  end
end
