# Handle the plans model and the worksheet.
#
# Plans are typically created from the GoalsController, but are displayed,
# edited, deleted, etc. from here. This is unusual for a REST app, but plans
# are not really created from a plan sheet itself, but from the concept of a
# set of Goals.
#
# Otherwise, updates, deletes, and shows work as expected.
#
# The Index operation (GET /plans/) displays the list of plans owned by the
# user, which is a different template.
class PlansController < ApplicationController
  before_action :authenticate_user!, only: %i[index]
  before_action :check_ownership, except: %i[index]

  def show
    @benchmarks = BenchmarksFixture.new
    @plan = Plan.find_by_id!(params.fetch(:id))
    @capacity_areas = @benchmarks.capacities.map { |c| c[:name] }
    @type_code_texts = @benchmarks.type_code_1s.values
  end

  def index
    @countries, @selectables = helpers.set_country_selection_options
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

  def destroy
    plan = Plan.find_by_id!(params.fetch(:id))
    plan.destroy
    flash[:alert] = "Deleted #{plan.name}"
    redirect_to plans_path
  end

  private

  def alert_and_redirect
    flash[:alert] = 'You are not allowed to access this plan'
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
