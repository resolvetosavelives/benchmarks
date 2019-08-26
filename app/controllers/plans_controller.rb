class PlansController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :check_ownership, except: [:index]

  def show
    @benchmarks = BenchmarksFixture.new
    @plan = Plan.find_by_id!(params.fetch(:id))
  end

  def index
    @plans = current_user.plans.order(updated_at: :desc)
  end

  def update
    plan = Plan.find_by_id!(params.fetch(:id))
    plan.update!(
      name: plan_params.fetch(:name),
      activity_map: JSON.parse(plan_params.fetch(:activity_map))
    )
    redirect_to plans_path
  end

  private

  def alert_and_redirect
    flash[:alert] = "You are not allowed to access this plan"
    redirect_to root_path
  end

  def check_ownership
    plan_id = params.fetch(:id).to_i
    if current_user
      alert_and_redirect if current_user.plan_ids.exclude?(plan_id)
    else
      alert_and_redirect unless plan_id == session[:plan_id]
    end
  end

  def plan_params
    params.require(:plan).permit(:name, :activity_map)
  end
end
