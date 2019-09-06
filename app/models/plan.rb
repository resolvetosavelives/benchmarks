# A draft plan. This consists of the assessment goals and a large activity map,
# organized by Technical Capacity and Benchmark Indicator. The activity_map
# field is an ActivityMap object.
class Plan < ApplicationRecord
  belongs_to :user, optional: true

  def activity_map
    ActivityMap.new self[:activity_map]
  end
end
