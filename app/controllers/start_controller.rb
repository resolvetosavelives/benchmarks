class StartController < ApplicationController
  before_action :require_country_id, only: %i[create show update]
  before_action :set_get_started_form

  def index
    @countries = Country.all_assessed
  end

  def create
    if @get_started_form.blank_assessment
      redirect_to start_path(id: @get_started_form.country_id, blank: true)
    else
      redirect_to start_path(id: @get_started_form.country_id)
    end
  end

  def show
    @country = @get_started_form.country
    @diseases = Disease.all.order(:created_at)
  end

  def update
    return show && render(:show) unless @get_started_form.valid?

    redirect_to plan_goals_url(
                  country_name: @get_started_form.country.name,
                  assessment_type: @get_started_form.assessment_type,
                  plan_term: @get_started_form.plan_term_s,
                  areas:
                    if @get_started_form.technical_area_ids.present?
                      @get_started_form.technical_area_ids.join("-")
                    else
                      nil
                    end,
                  diseases:
                    if @get_started_form.diseases.present?
                      @get_started_form.diseases.join("-")
                    else
                      nil
                    end
                )
  end

  private

  def set_get_started_form
    form_params = params.fetch(:get_started_form, {}).permit!.to_h
    form_params[:country_id] = @country_id if @country_id
    form_params[:blank_assessment] = params[:blank] if params.key?(:blank)
    @get_started_form = GetStartedForm.new(form_params)
  end

  def require_country_id
    @country_id = params[:id] || params.dig(:get_started_form, :country_id)

    return redirect_to(start_index_path) if @country_id.blank?
  end
end
