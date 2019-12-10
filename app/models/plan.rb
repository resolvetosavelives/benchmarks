# A draft plan. This consists of the assessment goals and a large activity map,
# organized by Technical Capacity and Benchmark Indicator. The activity_map
# field is an ActivityMap object.
class Plan < ApplicationRecord
  belongs_to :user, optional: true
  has_many :plan_benchmark_indicators, dependent: :destroy
  has_many :benchmark_indicators, through: :plan_benchmark_indicators
  has_many :plan_activities, dependent: :destroy do
    # when indicator has zero activities this will return +nil+
    def max_sequence_for_indicator(indicator_id)
      where(benchmark_indicator_id: indicator_id).maximum(:sequence)
    end
  end
  has_many :benchmark_indicator_activities, through: :plan_activities

  default_scope do
    # NB: these includes are structured in ways that prepare for the plans/show
    # template to be rendered along with its partials. this is because rendering
    # views is the longest/slowest part of the response.
    includes(
        {plan_activities: [:benchmark_indicator_activity, :benchmark_indicator]},
        {plan_benchmark_indicators: [:benchmark_indicator]}
    )
  end


  def update!(name:, benchmark_activity_ids:)
    current_activity_ids = benchmark_indicator_activity_ids
    # 1st, remove any needed
    remove_activity_ids = (current_activity_ids.to_set - benchmark_activity_ids.to_set).to_a
    remove_activities = self.plan_activities.
        where(benchmark_indicator_activity_id: remove_activity_ids).
        all
    remove_activities.each(&:destroy) # must call destroy to invoke callback for sequence
    # 2nd, add any needed
    add_activity_ids = benchmark_activity_ids - current_activity_ids
    add_activity_ids.each do |benchmark_activity_id|
      benchmark_activity = BenchmarkIndicatorActivity.find(benchmark_activity_id)
      benchmark_indicator = benchmark_activity.benchmark_indicator
      max_sequence = plan_activities.max_sequence_for_indicator(benchmark_indicator.id)
      max_sequence = 0 if max_sequence.blank?
      plan_activity = PlanActivity.new_for_benchmark_activity benchmark_activity
      plan_activity.plan = self
      plan_activity.sequence = (max_sequence + 1)
      self.plan_activities << plan_activity
    end
    # lastly, now that the associations are handled, perform a basic update
    super name: name
  end

  # @return an Array of benchmark_indicator_activity.id Integers
  #   sorted for readability
  def benchmark_indicator_activity_ids
    plan_activities.map(&:benchmark_indicator_activity).map(&:id).sort
  end

  ##
  # Constructs an Array containing n elements where n equals
  # +BenchmarkTechnicalArea.all.size+ (there are 18 as of year 2019) with each
  # element containing an integer that is the count of the activities for that
  # technical area, ordered by +BenchmarkTechnicalArea.sequence+, e.g.,
  # result[0] is TA 1, result[17] is TA.sequence==18
  # @return Array of Integers
  def count_activities_by_ta
    BenchmarkTechnicalArea.all.map do |bta|
      bta.benchmark_indicators.sum do |benchmark_indicator|
        activities_for(benchmark_indicator).size
      end
    end
  end

  def indicator_for(benchmark_indicator)
    plan_benchmark_indicators.detect do |pbi|
      benchmark_indicator.eql?(pbi.benchmark_indicator)
    end
  end

  def indicator_score_goal_for(benchmark_indicator)
    pbi = indicator_for(benchmark_indicator)
    [pbi, pbi&.score, pbi&.goal]
  end

  ##
  # arg is a BenchmarkIndicatorActivity
  def activities_for(benchmark_indicator)
    plan_activities.to_a.select do |plan_activity|
      benchmark_indicator.eql?(plan_activity.benchmark_indicator)
    end
  end

  ##
  # @return an Array of BenchmarkIndicatorActivity instances
  # this could be an opportunity for performance improvement since the plan/show
  # view calls this method for each benchmark indicator. perhaps switch it to
  # use Ajax instead of embedding the page within each indicator.
  def excluded_activities_for(benchmark_indicator)
    # note that "all possible" is scoped within the given benchmark_indicator
    all_possible_activities = benchmark_indicator.activities
    included_activities = plan_activities
                              .where(benchmark_indicator_activity_id: all_possible_activities)
                              .map(&:benchmark_indicator_activity)
    (all_possible_activities.to_set - included_activities.to_set).to_a
  end

  # Not used yet..
  #def activity_for(benchmark_indicator_activity)
  #  plan_activities.to_a.detect do |plan_activity|
  #    benchmark_indicator_activity.eql?(plan_activity.benchmark_indicator_activity)
  #  end
  #end

  ##
  # +goal_form_params+ will be, for example: {
  #   "country"=>"Nigeria",
  #   "assessment_type"=>"jee1",
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
  def self.from_goal_form(goal_attrs:, plan_name:, user: nil)
    named_ids = if goal_attrs[:assessment_type].eql?("spar_2018")
                  # score keys have 3 underscores
                  goal_attrs.select { |k, v| k.count('_').eql?(3) }.keys
                else # jee1 and jee2
                  # score keys have 2 underscores
                  goal_attrs.select { |k, v| k.count('_').eql?(2) }.keys
                end
    scores_and_goals_by_named_id = {}
    named_ids.each do |named_id|
      scores_and_goals_by_named_id[named_id] = {
          score: goal_attrs[named_id].to_i,
          goal: goal_attrs[named_id + "_goal"].to_i
      }
    end
    plan = Plan.new goal_attrs
                        .slice(:country, :assessment_type)
                        .merge({name: plan_name, user: user})
    plan_benchmark_indicators = []
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
      score = score_and_goal[:score]
      goal = score_and_goal[:goal]
      benchmark_indicators = assessment_indicator.benchmark_indicators.uniq
      benchmark_indicators.each do |benchmark_indicator|
        already_seen_indicator = plan_benchmark_indicators.any? do |pbi|
          pbi.benchmark_indicator.id.eql?(benchmark_indicator.id)
        end
        unless already_seen_indicator
          plan_benchmark_indicators << PlanBenchmarkIndicator.new(
              plan: plan,
              assessment_indicator: assessment_indicator,
              benchmark_indicator: benchmark_indicator,
              score: score,
              goal: goal
          )
          # reset the activity sequence for each unique benchmark_indicator
          plan_activity_sequence = 0
        end
        bia = benchmark_indicator.activities.
            where("level > :score AND level <= :goal", score_and_goal).
            order(:sequence).
            all
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
        plan.plan_benchmark_indicators = plan_benchmark_indicators
        plan.plan_activities = plan_activities
        plan.save!
      end
    end

    plan
  end

  def activity_map
    ActivityMap.new self[:activity_map]
  end

end
