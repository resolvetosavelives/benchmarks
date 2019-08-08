class GoalForm
  include ActiveModel::Model
  attr_accessor :country, :assessment_type

  def initialize(args)
    @country = args.fetch(:country)
    @assessment_type = args.fetch(:assessment_type)

    scores = args.fetch(:scores)
    self.class.attr_accessor(*(scores.keys))
    self.class.attr_accessor(*(scores.keys.map { |k| "#{k}_goal" }))

    scores.each { |key, value| send "#{key}=", value }
    scores.each { |key, value| send "#{key}_goal=", [value + 1, 5].min }
  end
end
