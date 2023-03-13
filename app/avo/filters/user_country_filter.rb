class UserCountryFilter < Avo::Filters::SelectFilter
  self.name = "Country"

  def apply(request, query, value)
    query.where(country_alpha3: value)
  end

  def options
    country_alpha3_to_name = {}
    countries_alpha_and_name = Country.all.pluck(:alpha3, :name)
    countries_alpha_and_name.each do |alpha3, name|
      country_alpha3_to_name[alpha3] = name
    end
    country_alpha3_to_name
  end
end
