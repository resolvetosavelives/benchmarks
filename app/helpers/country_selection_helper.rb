class CountryName
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

module CountrySelectionHelper
  def set_country_selection_options(placeholder)
    assessment_structure = JSON.load File.open './app/fixtures/assessments.json'
    assessments = Assessment.pluck(:country, :assessment_type)
    selectables =
      assessments.reduce(
        placeholder ? { '-- Select One --' => [] } : {}
      ) do |acc, (country, assessment_type)|
        acc[country] = [] unless acc[country]
        acc[country].push(
          {
            type: assessment_type,
            text: assessment_structure[assessment_type]['label']
          }
        )
        acc
      end

    countries = selectables.keys.sort.map { |c| CountryName.new(c) }
    [countries, selectables]
  end
end
