class PlansController < ApplicationController
  def show
    @benchmarks = BenchmarksFixture.new
    @plan = Plan.find_by_id!(params.fetch(:id))
  end

  def index
    @plans = Plan.all
  end

  def update
    plan = Plan.find_by_id!(params.fetch(:id))
    plan.update!(
      name: plan_params.fetch(:name),
      activity_map: JSON.parse(plan_params.fetch(:activity_map))
    )
    if current_user
      redirect_to action: 'index'
    else
      redirect_to new_user_session_path
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:name, :activity_map)
  end
end
