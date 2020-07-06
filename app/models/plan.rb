# This consists of the assessment goals
# organized by Technical Area and Benchmark Indicator. The action_map
# field is an ActionMap object.
class Plan < ApplicationRecord
  ASSESSMENT_TYPES = [
    1, # jee1
    2, # spar_2018
    3, # from-technical-areas
  ].freeze
  # TODO: update this implementation once the assessments page is modernized
  ASSESSMENT_TYPE_NAMED_IDS = %w[jee1 spar_2018 from-technical-areas].freeze
  TERM_TYPES = [100, 500] # 100 is 1-year, 500 is 5-year
  include PlanBuilder

  belongs_to :assessment
  belongs_to :user, optional: true
  has_many :goals, class_name: "PlanGoal", dependent: :destroy
  has_many :plan_actions, dependent: :destroy
  has_many :benchmark_indicator_actions, through: :plan_actions
  has_many :plan_diseases
  has_many :diseases, through: :plan_diseases

  delegate :alpha3, to: :country
  delegate :jee1?, :spar_2018?, :type_description, to: :assessment

  scope :deep_load, ->(id) {
    includes(:goals,
      {plan_actions: :benchmark_indicator_action})
      .where(id: id)
      .first
  }

  validates :assessment, presence: true
  validates :name, presence: true
  validates :term, inclusion: TERM_TYPES

  def is_5_year?
    term.eql?(TERM_TYPES.second)
  end

  def action_ids
    plan_actions.map(&:benchmark_indicator_action).map(&:id)
  end

  def update!(name:, benchmark_action_ids:)
    current_action_ids = benchmark_indicator_action_ids
    # Use +Set+ to avoid adding duplicates.
    current_action_id_set = current_action_ids.to_set
    benchmark_action_id_set = benchmark_action_ids.to_set
    # 1st, remove any needed.
    remove_action_ids = (current_action_id_set - benchmark_action_id_set).to_a
    remove_actions = plan_actions
      .where(benchmark_indicator_action_id: remove_action_ids)
      .all
    remove_actions.each(&:destroy)
    # 2nd, add any needed.
    add_action_ids = (benchmark_action_id_set - current_action_id_set).to_a
    add_action_ids.each do |benchmark_action_id|
      benchmark_action = BenchmarkIndicatorAction.find(benchmark_action_id)
      plan_action = PlanAction.new_for_benchmark_action benchmark_action
      plan_action.plan = self
      plan_actions << plan_action
    end
    # lastly, now that the associations are handled, perform a basic update
    super name: name
  end

  # @return an Array of benchmark_indicator_action.id Integers
  #   sorted for readability
  def benchmark_indicator_action_ids
    plan_actions.map(&:benchmark_indicator_action).map(&:id).sort
  end

  ##
  # Constructs an Array containing n elements where n equals
  # +BenchmarkTechnicalArea.all.size+ (there are 18 as of year 2019) with each
  # element containing an integer that is the count of the actions for that
  # technical area, ordered by +BenchmarkTechnicalArea.sequence+
  # @return Array of Integers
  # @deprecated No longer used as of June 2020 this logic has moved to JS in the browser, may remove.
  def count_actions_by_ta(benchmark_technical_areas)
    counts_by_ta_id = Array.new(benchmark_technical_areas.size, 0)
    plan_actions.reduce(counts_by_ta_id) do |accumulator_h, action|
      # sequence is one-based so subtract one to make zero-based
      ta_sequence = action.benchmark_technical_area.sequence - 1
      accumulator_h[ta_sequence] += 1
      accumulator_h
    end
    counts_by_ta_id.compact
  end

  # @deprecated No longer used as of June 2020 this logic has moved to JS in the browser, may remove.
  def count_actions_by_type
    counts_by_type = Array.new(
      BenchmarkIndicatorAction::ACTION_TYPES.size, 0
    )
    plan_actions.each do |action|
      # some BIA's have no action types and those are nil, we absorb with +&+
      action.benchmark_indicator_action.action_types&.each do |type_num|
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
  # arg is a BenchmarkIndicatorAction
  def actions_for(benchmark_indicator)
    plan_actions.to_a.select do |plan_action|
      plan_action.benchmark_indicator_id.eql?(benchmark_indicator.id)
    end
  end

  ##
  # @return an Array of BenchmarkIndicatorAction instances
  # this could be an opportunity for performance improvement since the plan/show
  # view calls this method for each benchmark indicator. perhaps switch it to
  # use Ajax instead of embedding the page within each indicator.
  def excluded_actions_for(benchmark_indicator)
    # note that "all possible" is scoped within the given benchmark_indicator
    all_possible_actions = benchmark_indicator.actions
    included_actions = plan_actions
      .where(benchmark_indicator_action_id: all_possible_actions)
      .map(&:benchmark_indicator_action)
    (all_possible_actions.to_set - included_actions.to_set).to_a
  end
end
