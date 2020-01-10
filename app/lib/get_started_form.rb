class GetStartedForm
  include ActiveModel::Model

  # actual form inputs
  attr_accessor :country_id, :assessment_type, :plan_by_technical_ids, :plan_term
  attr_writer :technical_area_ids
  # object instances that should result from the inputs
  attr_accessor :country, :assessment

  validates :country, :assessment, presence: true
  validates :plan_term, inclusion: [1, 5] # in years

  def initialize(attrs = {})
    super attrs
    init_technical_area_ids
    numeric_plan_term
    set_country
    set_assessment
  end

  def init_technical_area_ids
    # when blank, initialize to an array
    @technical_area_ids = [] if @technical_area_ids.blank?
    # when any values, convert them from string to integer
    @technical_area_ids = @technical_area_ids.map(&:to_i)
  end

  def plan_by_technical_ids?
    plan_by_technical_ids.eql?("1")
  end

  def numeric_plan_term
    self.plan_term = plan_term.to_i if plan_term.present?
  end

  def set_country
    self.country = Country.find_by_id country_id
  end

  def set_assessment
    if country.present? && assessment_type.present? && is_known?(assessment_type)
      assessment_publication = AssessmentPublication.find_by_named_id(assessment_type)
      if assessment_publication.present?
        self.assessment = Assessment.find_by_country_alpha3_and_assessment_publication_id(country.alpha3, assessment_publication.id)
      end
    end
  end

  def is_known?(assessment_type)
    Plan::ASSESSMENT_TYPE_NAMED_IDS.include?(assessment_type)
  end

  def plan_term_s
    "#{plan_term}-year" if plan_term.present?
  end

  # return IDs only when the coresponding checkbox is selected
  def technical_area_ids
    if plan_by_technical_ids?
      @technical_area_ids
    else
      []
    end
  end

end
