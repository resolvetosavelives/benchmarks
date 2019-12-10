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
# user, and populates dropdown menus for starting a new plan.
#
# An unauthenticated user may get to this stage. This user is still allowed to
# edit the draft plan they have created, and the plan will be associated with
# their browser session. They'll be prompted to log in when they try to save
# the draft plan. After login (even if an account creation is involved), the
# draft plan will be attached to their account.
class PlansController < ApplicationController
  before_action :authenticate_user!, only: %i[index]
  before_action :check_ownership, except: %i[index create]

  def show
    @benchmark_technical_areas = BenchmarkTechnicalArea.all
    @benchmark_indicators = BenchmarkIndicator.all
    @plan = Plan.find(params.fetch(:id))
  end

  # TODO: test coverage for this, and include for the session state part
  def create
    goal_form_params = goal_params
    plan = Plan.from_goal_form(
        goal_attrs: goal_form_params.to_h,
        plan_name: "#{goal_form_params.fetch(:country)} draft plan",
        user: current_user
    )
    if plan.new_record?
      flash[:notice] = "Could not save your plan, something went wrong."
      redirect_back fallback_location: root_path
      return
    end
    session[:plan_id] = plan.id unless current_user
    redirect_to plan
  end

  def index
    @countries, @selectables = helpers.set_country_selection_options(true)
    @plans = current_user.plans.order(updated_at: :desc)
    @assessments = JSON.load File.open './app/fixtures/assessments.json'
    @data_dictionary = JSON.load File.open './app/fixtures/data_dictionary.json'
  end

  # TODO: test coverage for this
  def update
    plan = Plan.find_by_id!(params.fetch(:id))
    benchmark_activity_ids = JSON.parse(plan_params.fetch(:benchmark_activity_ids))
    name = plan_params.fetch(:name)
    plan.update!(
        name:                   name,
        benchmark_activity_ids: benchmark_activity_ids
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
    params.require(:plan).permit(:name, :benchmark_activity_ids)
  end

  def goal_params
    params.require(:goal_form).permit!
  end
end
