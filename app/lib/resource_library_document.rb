require 'csv'

class ResourceLibraryDocument < Struct.new(:title, :description, :author, :date, :relevant_pages, :download_url, :thumbnail_url, :technical_area, :resource_type)
  PATH_TO_CSV_FILE = Rails.root.join("data", "resource_library_documents_from_airtable.csv").freeze
  # NB: these are in singular form because that is how they are in AirTable/CSV data source
  RESOURCE_TYPES = ["Briefing Note", "Case Study", "Example", "Guideline", "Manual", "Template", "Tool", "Training Package"].freeze

  def self.all_from_csv
    array_of_rows = CSV.read(PATH_TO_CSV_FILE)
    array_of_rows.drop(1).map do |row|
      new_from_csv(
        row[2]&.strip,
        row[3]&.strip,
        row[7]&.strip,
        row[8]&.strip,
        row[11]&.strip,
        row[1]&.strip,
        row[13]&.strip,
        row[4]&.strip,
        row[6]&.strip
      )
    end
  end

  def self.new_from_csv(title, description, author, date, relevant_pages, download_url, thumbnail_url, technical_area, resource_type)
    new(
      title,
      description,
      author,
      date,
      relevant_pages,
      extract_download_url(download_url),
      extract_download_url(thumbnail_url),
      technical_area,
      resource_type
    )
  end

  ##
  # if there are multiple then it returns only the last which would have been the first-added attachment.
  # example arg: "One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso (FRENCH).pdf (https://dl.airtable.com/.attachments/d273fbb3427d94635ddb734a14f95e26/98c1a677/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFasoFRENCH.pdf),One health zoonotic disease prioroitization for Multisectoral Engagement in Burkina Faso.pdf (https://dl.airtable.com/.attachments/a78a3c2b524ddac30133b6aa882817aa/15400a04/OnehealthzoonoticdiseaseprioroitizationforMultisectoralEngagementinBurkinaFaso.pdf)"
  def self.extract_download_url(attachments_field)
    return "" if attachments_field.blank?
    # tokenize into an array based on comma. most have one but some have two.
    attachments = attachments_field.split(",")
    # take the last one which was probably the first added
    first_attachment = attachments[attachments.size - 1]
    # pluck out the URL from within the parentheses at the end of this string
    match = first_attachment.match(/.*\((.*)\)\Z/)
    return match[1] if match
  end

  def self.resource_type_ordinal(resource_type_name)
    index = RESOURCE_TYPES.index(resource_type_name)
    return nil if index.nil?
    index + 1
  end

  def resource_type_ordinal
    self.class.resource_type_ordinal self.resource_type
  end

end
