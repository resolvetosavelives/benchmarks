class PlanActivity < ApplicationRecord
  belongs_to :plan
  belongs_to :benchmark_indicator_activity
  belongs_to :benchmark_indicator
  after_destroy :update_sequences

  default_scope { includes(:benchmark_indicator_activity).order(:sequence) }

  def self.new_for_benchmark_activity(benchmark_indicator_activity)
    new(
      benchmark_indicator_activity: benchmark_indicator_activity,
      benchmark_indicator_id: benchmark_indicator_activity.benchmark_indicator_id
    )
  end

  ##
  # This is a rare reason to use a SQL statement directly.
  # This is for when an activity is deleted from a Plan, the other plan
  # activities' sequence field will be updated so as to not leave gaps.
  # For example, activities with sequence [1,2,3,4,5] when the middle one is
  # deleted, it would leave [1,2,4,5]. Over time these gaps would drift further
  # apart and could lead to strange behavior. In the same example, with this
  # code, when [1,2,3,4,5] and the 3rd one is deleted, what remains is [1,2,3,4]
  def update_sequences
    update_sql = "UPDATE #{self.class.table_name} SET sequence = sequence - 1" \
      "WHERE benchmark_indicator_id = #{benchmark_indicator_id}" \
      "  AND sequence >= #{sequence}"
    ActiveRecord::Base.connection.exec_query update_sql
  end
end
