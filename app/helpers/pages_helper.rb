module PagesHelper
  def technical_area_to_id(technical_areas, technical_area_name)
    technical_areas.detect { |ta| ta.text.eql?(technical_area_name) }&.id
  end

  ##
  # converts the given string +phrase+ to be suitable for jQuery selectors and DOM attributes
  # for example: ("Best Practices") => "best_practices"
  def phrase_to_underscore(phrase)
    phrase.downcase.gsub(" ", "_")
  end

  ##
  # arg +idx+ is a zero-based index and converts it to a one-based index
  # for example: (0) => 1
  def zero_to_one_index(idx)
    idx + 1
  end
end
