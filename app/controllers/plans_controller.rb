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
  # workaround for XHR being unable to detect a redirect. JS handles this on the client.
  GET_STARTED_REDIRECT_KEY = "Get-Started-Redirect-To:"

  before_action :authenticate_user!, only: %i[index]
  before_action :check_ownership, except: %i[get_started goals index create]

  ##
  # the purpose of this action is to select which assessment upon which to base a plan
  def get_started
    @countries = Country.all_assessed
    @technical_areas_jee1 = AssessmentTechnicalArea.jee1
    @technical_areas_spar_2018 = AssessmentTechnicalArea.spar_2018
    @get_started_form = GetStartedForm.new get_started_params.to_h
    @redirect_key = GET_STARTED_REDIRECT_KEY
    if request.post? && request.xhr?
      if @get_started_form.valid?
        url = plan_goals_url(
          country_name: @get_started_form.country.name,
          assessment_type: @get_started_form.assessment_type,
          plan_term: @get_started_form.plan_term_s,
          areas: @get_started_form.technical_area_ids.join("-")
        )
        Rails.logger.info "Redirect workaround for an XHR request to URL: #{url}"
        render plain: "#{GET_STARTED_REDIRECT_KEY}#{url}"
        return
      else
        render layout: false
        return
      end
    end
    # will just render the view template
  end

  ##
  # the purpose of this action is to edit goal values for a plan's indicators
  def goals
    assessment_type = params[:assessment_type]
    country_name = params[:country_name]
    technical_area_ids = params[:areas].to_s.split("-")
    country = Country.find_by_name country_name
    assessment_publication = AssessmentPublication.find_by_named_id assessment_type
    @assessment = Assessment.find_by_country_alpha3_and_assessment_publication_id country.try(:alpha3), assessment_publication.id
    if @assessment.blank?
      render "assessment_not_found"
      return
    end
    @publication = @assessment.assessment_publication
    @plan = Plan.new_from_assessment(
      assessment: @assessment,
      technical_area_ids: technical_area_ids,
      is_5_year_plan: params[:plan_term].start_with?("5"))
  end

  # TODO: test coverage for this, and include for the session state part
  def create
    assessment = Assessment.find(plan_create_params.fetch(:assessment_id))
    @plan = Plan.create_from_goal_form(
      indicator_attrs: plan_create_params.fetch(:indicators),
      assessment: assessment,
      is_5_year_plan: plan_create_params.fetch(:term).start_with?("5"),
      plan_name: "#{assessment.country.name} draft plan",
      user: current_user
    )
    unless @plan.persisted?
      flash[:notice] = "Could not save your plan, something went wrong."
      redirect_back fallback_location: root_path
      return
    end
    session[:plan_id] = @plan.id unless current_user
    redirect_to @plan
  end

  def show
    @benchmark_technical_areas = BenchmarkTechnicalArea.all
    @benchmark_indicators = BenchmarkIndicator.all
    @all_activities = BenchmarkIndicatorActivity.all
    @technical_area_abbrev_map = BenchmarkTechnicalArea.to_abbreviation_map
    @nudges_by_activity_type_json = File.read(Rails.root.join("app", "fixtures", "nudges_for_activity_types.json"))
    @plan = Plan.find(params.fetch(:id))
  end

  # TODO: test coverage for this
  def update
    plan = Plan.find_by_id!(params.fetch(:id))
    benchmark_activity_ids = JSON.parse(plan_update_params.fetch(:benchmark_activity_ids))
    name = plan_update_params.fetch(:name)
    plan.update!(
      name: name,
      benchmark_activity_ids: benchmark_activity_ids
    )
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

  def get_started_params
    params.fetch(:get_started_form, {}).permit!
  end

  def plan_create_params
    params.require(:plan).permit(:assessment_id, :term, indicators: {})
  end

  def plan_update_params
    params.require(:plan).permit(:id, :name, :benchmark_activity_ids)
  end

  def goal_params
    params.require(:goal_form).permit!
  end
end
