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

  scope :deep_load, ->(id) {
    includes(:goals,
      {plan_activities: :benchmark_indicator_activity})
      .where(id: id)
      .first
  }

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
  # technical area, ordered by +BenchmarkTechnicalArea.sequence+
  # @return Array of Integers
  def count_activities_by_ta(benchmark_technical_areas)
    counts_by_ta_id = Array.new(benchmark_technical_areas.size, 0)
    plan_activities.reduce(counts_by_ta_id) do |accumulator_h, activity|
      # sequence is one-based so subtract one to make zero-based
      ta_sequence = activity.benchmark_technical_area.sequence - 1
      accumulator_h[ta_sequence] += 1
      accumulator_h
    end
    counts_by_ta_id.compact
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
      goal.benchmark_indicator_id.eql?(benchmark_indicator.id)
    end
  end

  def goal_value_for(benchmark_indicator:)
    goals.detect do |goal|
      goal.benchmark_indicator_id.eql?(benchmark_indicator.id)
    end&.value
  end

  ##
  # arg is a BenchmarkIndicatorActivity
  def activities_for(benchmark_indicator)
    plan_activities.to_a.select do |plan_activity|
      plan_activity.benchmark_indicator_id.eql?(benchmark_indicator.id)
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
