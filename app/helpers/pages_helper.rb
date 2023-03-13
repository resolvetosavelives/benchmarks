module PagesHelper
  def technical_area_texts_to_ids(all_technical_areas, array_of_ta_texts)
    return "" if array_of_ta_texts.blank? || !array_of_ta_texts.is_a?(Array)

    array_of_ta_texts
      .map do |technical_area_text|
        technical_area_match =
          all_technical_areas.detect do |technical_area|
            technical_area.text.eql?(technical_area_text)
          end
        technical_area_match.id if technical_area_match.present?
      end
      .compact
      .uniq
  end

  def ta_ids_to_css_classes(technical_area_ids)
    technical_area_ids.map { |ta_id| "technical-area-#{ta_id}" }.join(" ")
  end

  def document_present?(document)
    [
      document.title,
      document.author,
      document.description,
      document.relevant_pages,
      document.thumbnail_url
    ].any?(&:present?)
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
