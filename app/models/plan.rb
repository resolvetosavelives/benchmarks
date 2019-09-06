class Plan < ApplicationRecord
  belongs_to :user, optional: true

  def activity_map
    ActivityMap.new self[:activity_map]
  end
end
