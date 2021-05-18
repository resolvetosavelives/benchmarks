class GetStartedForm
  include ActiveModel::Model

  # actual form inputs
  attr_accessor :country_id,
                :assessment_type,
                :plan_by_technical_ids,
                :plan_term,
                :diseases,
                :blank_assessment
  attr_writer :technical_area_ids

  # object instances that should result from the inputs
  attr_accessor :country, :assessment, :diseases

  validates :country, :assessment, presence: true
  validates :plan_term, inclusion: [1, 5], unless: :blank_assessment
  validate :valid_diseases?

  def initialize(attrs = {})
    super attrs
    init_technical_area_ids
    init_diseases
    numeric_plan_term
    set_country
    set_assessment
  end

  def init_technical_area_ids
    @technical_area_ids = [] if @technical_area_ids.blank?
    @technical_area_ids = @technical_area_ids.map(&:to_i)
  end

  def init_diseases
    @diseases = [] if @diseases.blank?
    @diseases = @diseases.map(&:to_i)
  end

  def plan_by_technical_ids?
    plan_by_technical_ids.eql?("1")
  end

  def numeric_plan_term
    self.plan_term = plan_term.to_i if plan_term.present?
  end

  def set_country
    if country_id.present?
      # we use the +with_assessments_and_publication+ method here because we want to
      # fetch additional data to optimize for which data the view template will use.
      self.country = Country.with_assessments_and_publication(country_id)
    end
  end

  def set_assessment
    if country && blank_assessment
      self.assessment_type = "jee2"
      self.assessment =
        Assessment.new(
          assessment_publication: AssessmentPublication.jee2,
          country: country
        )
      return
    end

    if country.present? && assessment_type.present? &&
         is_known?(assessment_type)
      assessment_publication =
        AssessmentPublication.find_by_named_id(assessment_type)
      if assessment_publication.present?
        # we use the +with_publication+ method here because we want to
        # fetch additional data to optimize for which data the view template will use.
        self.assessment =
          Assessment.with_publication(country.alpha3, assessment_publication.id)
            .first
      end
    end
  end

  def is_known?(assessment_type)
    Plan::ASSESSMENT_TYPE_NAMED_IDS.include?(assessment_type)
  end

  def plan_term_s
    "#{plan_term}-year" if plan_term.present?
  end

  # return IDs only when the corresponding checkbox is selected
  def technical_area_ids
    plan_by_technical_ids? ? @technical_area_ids : []
  end

  def valid_diseases?
    if Disease.where(id: diseases).count != diseases.length
      errors.add(:diseases, "Invalid disease id")
    end
  end
end
