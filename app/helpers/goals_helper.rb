module GoalsHelper
  DISPLAY_ABBREVIATIONS = JSON.load(File.read(File.join(
    Rails.root,
    "/app/fixtures/assessment_display_abbreviations.json"
  )))

  ##
  # takes an arg such as "jee1_ind_p12" and returns "P.1.2", or empty string
  def abbrev_from_named_id(named_id)
    DISPLAY_ABBREVIATIONS[named_id] || ""
  end
end
