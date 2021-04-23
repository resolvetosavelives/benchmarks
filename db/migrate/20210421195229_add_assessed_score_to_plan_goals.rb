class AddAssessedScoreToPlanGoals < ActiveRecord::Migration[6.1]
  def change
    add_column :plan_goals, :assessed_score, :integer
  end
end
