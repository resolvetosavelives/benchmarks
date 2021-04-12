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
class PlansController < ApplicationController # workaround for XHR being unable to detect a redirect. JS handles this on the client.
  GET_STARTED_REDIRECT_KEY = "Get-Started-Redirect-To:"

  before_action :authenticate_user!, only: %i[index]
  before_action :check_ownership, except: %i[get_started goals index create]

  ##
  # the purpose of this action is to edit goal values for a plan's indicators
  def goals
    assessment_type = params[:assessment_type]
    country_name = params[:country_name]
    technical_area_ids = params[:areas].to_s.split("-")
    @disease_ids = params[:diseases]
    country = Country.find_by_name country_name
    @publication = AssessmentPublication.find_by_named_id assessment_type
    if country.present? && @publication.present?
      @assessment =
        Assessment.deep_load(country.try(:alpha3), @publication.try(:id))
    end
    if @assessment.blank?
      render "assessment_not_found"
      return
    end
    @plan =
      Plan.new_from_assessment(
        assessment: @assessment,
        technical_area_ids: technical_area_ids,
        is_5_year_plan: params[:plan_term].start_with?("5")
      )
  end

  # TODO: test coverage for the session state part
  def create
    assessment = Assessment.find(plan_create_params.fetch(:assessment_id))
    disease_ids = plan_create_params.fetch(:disease_ids).to_s.split("-")
    @plan =
      Plan.create_from_goal_form(
        indicator_attrs: plan_create_params.fetch(:indicators),
        assessment: assessment,
        is_5_year_plan: plan_create_params.fetch(:term).start_with?("5"),
        plan_name: "#{assessment.country.name} draft plan",
        disease_ids: disease_ids,
        user: current_user
      )
    unless @plan.persisted?
      flash[:notice] = "Could not save your plan, something went wrong."
      redirect_back fallback_location: root_path
      return
    end
    session[:plan_id] = @plan.id unless current_user
    redirect_to @plan
  rescue Exceptions::InvalidDiseasesError => e
    flash[:notice] = e.message
    redirect_back fallback_location: root_path
  end

  def show
    benchmark_document = BenchmarkDocument.new
    @benchmark_technical_areas = benchmark_document.technical_areas
    @benchmark_indicators = benchmark_document.indicators
    @all_actions = benchmark_document.actions
    @diseases = Disease.all
    @nudges_by_action_type_json =
      File.read(
        Rails.root.join("app", "fixtures", "nudges_for_action_types.json")
      )
    @plan = Plan.deep_load(params.fetch(:id))
    @reference_library_documents =
      ReferenceLibraryDocument.all.map { |d| [d.id, d] }.to_h
  end

  # TODO: test coverage for this
  def update
    plan = Plan.find_by_id!(params.fetch(:id))
    benchmark_action_ids =
      JSON.parse(plan_update_params.fetch(:benchmark_action_ids))
    name = plan_update_params.fetch(:name)
    plan.update!(name: name, benchmark_action_ids: benchmark_action_ids)
    redirect_to plans_path
  end

  def index
    @plans = current_user.plans.order(updated_at: :desc)
  end

  def destroy
    plan = Plan.find_by_id!(params.fetch(:id))
    plan.destroy
    flash[:alert] = "Deleted #{plan.name}"
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

  def plan_create_params
    params
      .require(:plan)
      .permit(:assessment_id, :term, :disease_ids, indicators: {})
  end

  def plan_update_params
    params.require(:plan).permit(:id, :name, :benchmark_action_ids)
  end

  def goal_params
    params.require(:goal_form).permit!
  end
end
