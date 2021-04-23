# This consists of the assessment goals
# organized by Technical Area and Benchmark Indicator. The action_map
# field is an ActionMap object.
class Plan < ApplicationRecord
  ASSESSMENT_TYPES = [
    1, # jee1
    2, # spar_2018
    3 # jee2
  ].freeze

  # TODO: update this implementation once the assessments page is modernized
  ASSESSMENT_TYPE_NAMED_IDS = %w[jee1 spar_2018 jee2].freeze
  TERM_TYPES = [100, 500] # 100 is 1-year, 500 is 5-year
  include PlanBuilder

  belongs_to :assessment
  belongs_to :user, optional: true
  has_many :goals, class_name: "PlanGoal", dependent: :destroy
  has_many :plan_actions, dependent: :destroy
  has_many :benchmark_indicator_actions, through: :plan_actions
  has_many :plan_diseases
  has_many :diseases, through: :plan_diseases, dependent: :destroy
  has_many :reference_library_documents, through: :benchmark_indicator_actions

  delegate :alpha3, to: :country
  delegate :jee1?, :spar_2018?, :type_description, to: :assessment

  scope :deep_load,
        ->(id) {
          includes(
              :goals,
              {
                plan_actions: {
                  benchmark_indicator_action: :reference_library_documents
                }
              }
            )
            .where(id: id)
            .first
        }

  scope :purgeable, -> { where("updated_at < ?", 2.weeks.ago).where(user: nil) }

  validates :assessment, presence: true
  validates :name, presence: true
  validates :term, inclusion: TERM_TYPES

  def self.purge_old_plans!(dry_run: false)
    dry_run ? purgeable : purgeable.delete_all
  end

  def is_5_year?
    term.eql?(TERM_TYPES.second)
  end

  def action_ids
    benchmark_indicator_actions.pluck(:id)
  end

  def update!(name:, benchmark_action_ids:)
    current_action_ids = benchmark_indicator_action_ids

    # Use +Set+ to avoid adding duplicates.
    current_action_id_set = current_action_ids.to_set
    benchmark_action_id_set = benchmark_action_ids.to_set

    # 1st, remove any needed.
    remove_action_ids = (current_action_id_set - benchmark_action_id_set).to_a
    remove_actions =
      plan_actions.where(benchmark_indicator_action_id: remove_action_ids).all
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
    included_actions =
      plan_actions
        .where(benchmark_indicator_action_id: all_possible_actions)
        .map(&:benchmark_indicator_action)
    (all_possible_actions.to_set - included_actions.to_set).to_a
  end

  def current_and_target_scores
    goals.reduce({}) do |cats, goal|
      cats[goal.benchmark_indicator_id] = [goal.assessed_score, goal.value]
      cats
    end
  end

  def as_json(options = {})
    super(
      options.reverse_merge(
        only: %i[id name term],
        include: [:diseases],
        methods: %i[action_ids disease_ids]
      )
    )
  end
end
