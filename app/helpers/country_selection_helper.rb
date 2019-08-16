class CountryName
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

module CountrySelectionHelper
  def set_country_selection_options
   assessments = Assessment.pluck(:country, :assessment_type)
   selectables =
     assessments.reduce({}) do |acc, (country, assessment_type)|
       acc[country] = [] unless acc[country]
       acc[country].push(assessment_type)
       acc
     end

   countries = selectables.keys.sort.map { |c| CountryName.new(c) }
   [countries, selectables]
  end
end
