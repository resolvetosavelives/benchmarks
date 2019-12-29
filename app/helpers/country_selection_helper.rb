class CountryName
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

module CountrySelectionHelper
  def set_country_selection_options(should_use_placeholder = true)
    default_placeholder = "-- Select One --"
    placeholder = should_use_placeholder ? { default_placeholder => [] } : {}
    assessments = Assessment.all
    assessment_publications = AssessmentPublication.all
    assessment_publications_h = {}
    assessment_publications.each do |ap|
      assessment_publications_h[ap.named_id] = ap.name
    end
    countries = []
    countries << CountryName.new(default_placeholder) if should_use_placeholder
    selectables = assessments.reduce(placeholder) do |accumulator_hash, assessment|
      country_name = assessment.country.name
      countries << assessment.country
      accumulator_hash[country_name] = [] unless accumulator_hash[country_name]
      accumulator_hash[country_name].push(
        {
          type: assessment.assessment_type,
          text: assessment_publications_h[assessment.assessment_type],
        }
      )
      accumulator_hash
    end
    countries.uniq!
    countries.sort! {|c1, c2| c1.name <=> c2.name }
    [countries, selectables]
  end
end
