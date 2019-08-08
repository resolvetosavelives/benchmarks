class GoalForm
  attr_accessor :country, :assessment_type

  def initialize(args)
    @country = args.fetch(:country)
    @assessment_type = args.fetch(:assessment_type)

    scores = args.fetch(:scores)
    self.class.attr_accessor(*(scores.map { |score| score['indicator_id'] }))

    scores.each { |score| send "#{score['indicator_id']}=", score['score'] }
    scores.each do |score|
      send "#{score['indicator_id']}_goal=", [score['score'] + 1, 5].min
    end
  end
end
