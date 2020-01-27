# This consists of the assessment goals 
# organized by Technical Area and Benchmark Indicator. The activity_map
# field is an ActivityMap object.
class Plan < ApplicationRecord
  ASSESSMENT_TYPES = [
    1, # jee1
    2, # spar_2018
    3, # from-technical-areas
  ].freeze
  # TODO: update this implementation once the assessments page is modernized
  ASSESSMENT_TYPE_NAMED_IDS = %w{jee1 spar_2018 from-technical-areas}.freeze
  TERM_TYPES = [100, 500] # 100 is 1-year, 500 is 5-year
  include PlanBuilder

  belongs_to :assessment
  belongs_to :user, optional: true
  has_many :goals, class_name: "PlanGoal", dependent: :destroy
  has_many :plan_activities, dependent: :destroy
  has_many :benchmark_indicator_activities, through: :plan_activities

  delegate :alpha3, to: :country
  delegate :jee1?, :spar_2018?, :type_description, to: :assessment

  default_scope do
    # NB: these includes are structured in ways that prepare for the plans/show
    # template to be rendered along with its partials. this is because rendering
    # views is the longest/slowest part of the response.
    includes(
      {assessment: [:scores]},
      {plan_activities: {benchmark_indicator_activity: :benchmark_indicator}},
      {goals: [:benchmark_indicator, :assessment_indicator]}
    )
  end

  validates :assessment, presence: true
  validates :name, presence: true
  validates :term, inclusion: TERM_TYPES

  def is_5_year?
    term.eql?(TERM_TYPES.second)
  end

  def activity_ids
    plan_activities.map(&:benchmark_indicator_activity).map(&:id)
  end

  def update!(name:, benchmark_activity_ids:)
    current_activity_ids = benchmark_indicator_activity_ids
    # Use +Set+ to avoid adding duplicates.
    current_activity_id_set = current_activity_ids.to_set
    benchmark_activity_id_set = benchmark_activity_ids.to_set
    # 1st, remove any needed.
    remove_activity_ids = (current_activity_id_set - benchmark_activity_id_set).to_a
    remove_activities = plan_activities
      .where(benchmark_indicator_activity_id: remove_activity_ids)
      .all
    remove_activities.each(&:destroy)
    # 2nd, add any needed.
    add_activity_ids = (benchmark_activity_id_set - current_activity_id_set).to_a
    add_activity_ids.each do |benchmark_activity_id|
      benchmark_activity = BenchmarkIndicatorActivity.find(benchmark_activity_id)
      plan_activity = PlanActivity.new_for_benchmark_activity benchmark_activity
      plan_activity.plan = self
      plan_activities << plan_activity
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

  def count_activities_by_type
    counts_by_type = Array.new(
      BenchmarkIndicatorActivity::ACTIVITY_TYPES.size, 0
    )
    plan_activities.each do |activity|
      # some BIA's have no activity types and those are nil, we absorb with +&+
      activity.benchmark_indicator_activity.activity_types&.each do |type_num|
        counts_by_type[type_num - 1] += 1
      end
    end
    counts_by_type
  end

  def goal_for(benchmark_indicator:)
    goals.detect do |goal|
      benchmark_indicator.eql?(goal.benchmark_indicator)
    end
  end

  def goal_value_for(benchmark_indicator:)
    goals.detect do |goal|
      benchmark_indicator.eql?(goal.benchmark_indicator)
    end&.value
  end

  ##
  # arg is a BenchmarkIndicatorActivity
  def activities_for(benchmark_indicator)
    plan_activities.to_a.select do |plan_activity|
      benchmark_indicator.eql?(plan_activity.benchmark_indicator_activity.benchmark_indicator)
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
end
