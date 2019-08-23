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
    if current_user
      redirect_to action: 'index'
    else
      redirect_to new_user_session_path
    end
  end

  private

  def check_ownership
    if current_user
      if current_user.plan_ids.exclude?(params.fetch(:id).to_i)
        flash[:alert] = "You are not allowed to access this plan"
        redirect_to root_path
      end
    else
      unless params.fetch(:id).to_i == session[:plan_id]
        flash[:alert] = "You are not allowed to access this plan"
        redirect_to root_path
      end
    end
  end

  def plan_params
    params.require(:plan).permit(:name, :activity_map)
  end
end
