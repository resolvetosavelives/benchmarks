class StartController < ApplicationController
  def index
    @countries = Country.all_assessed
    @get_started_form = GetStartedForm.new({})
  end

  def create
    country_id = params.dig(:get_started_form, :country_id)
    redirect_to country_id ? start_path(id: country_id) : start_index
  end

  def show
    @get_started_form = GetStartedForm.new(get_started_params)
    @country = Country.find(@get_started_form.country_id)
    @technical_areas_jee1 = AssessmentTechnicalArea.jee1
    @technical_areas_spar_2018 = AssessmentTechnicalArea.spar_2018
    @diseases = Disease.all.order(:created_at)
  end

  def update
    @get_started_form = GetStartedForm.new(get_started_params)

    unless @get_started_form.valid?
      show
      return render :show
    end

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

  def get_started_params
    params
      .fetch(:get_started_form, {})
      .permit!
      .to_h
      .merge(country_id: params.fetch(:id))
  end
end
