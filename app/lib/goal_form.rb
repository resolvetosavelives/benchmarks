def create_goal(score)
  Score.new ([[score.value + 1, 5].min, 2].max)
end

# A GoalForm object that corresponds to the form in the visible goals page
#
# Accessors get created for every assessment indicator score and for the
# assessment indicator goal and should correspond to the form in the HTML page.
# The accessors are the form of `<assessment_type>_ind_<indicator>` and
# `<assessment_type>_ind_<indicator>=. This effectively looks like
# `spar_2018_ind_c92` and `spar_2018_ind_c92=`.
class GoalForm
  include ActiveModel::Model
  attr_accessor :country, :assessment_type

  def initialize(args)
    @country = args.fetch(:country)
    @assessment_type = args.fetch(:assessment_type)

    scores = args.fetch(:scores)
    self.class.attr_accessor(*(scores.keys))
    self.class.attr_accessor(*(scores.keys.map { |k| "#{k}_goal" }))

    scores.each { |key, score| send "#{key}=", score.value }
    scores.each { |key, score| send "#{key}_goal=", create_goal(score).value }
  end

end
