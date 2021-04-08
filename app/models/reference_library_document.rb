# frozen_string_literal: true

require "csv"

class ReferenceLibraryDocument < ApplicationRecord
  include ReferenceLibraryDocumentSeed

  has_and_belongs_to_many :benchmark_indicator_actions,
                          join_table: :actions_and_documents

  validates :download_url, uniqueness: true

  PATH_TO_CSV_FILE =
    Rails
      .root
      .join("data", "reference_library_documents_from_airtable.csv")
      .freeze

  # NB: these are in singular form because that is how they are in AirTable/CSV data source
  REFERENCE_TYPES = [
    "Briefing Note",
    "Case Study",
    "Example",
    "Guideline",
    "Manual",
    "Template",
    "Tool",
    "Training Package"
  ].freeze

  def self.import!(csv = PATH_TO_CSV_FILE)
    record_hashes_from_csv(csv).each { |r| ReferenceLibraryDocument.create(r) }
  end

  def self.record_hashes_from_csv(csv)
    CSV.read(csv).drop(1) # drop header row
      .map { |row| record_hash_from_row(row) }
  end

  def self.record_hash_from_row(row)
    {
      download_url: extract_download_url(row[1]&.strip),
      title: row[2]&.strip,
      description: row[3]&.strip,
      technical_area: row[4]&.strip,
      reference_type: row[6]&.strip,
      author: row[7]&.strip,
      date: row[8]&.strip,
      relevant_pages: row[11]&.strip,
      thumbnail_url: extract_download_url(row[13]&.strip)
    }
  end

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

  def self.reference_type_ordinal(reference_type_name)
    index = REFERENCE_TYPES.index(reference_type_name)
    return nil if index.nil?

    index + 1
  end

  def reference_type_ordinal
    self.class.reference_type_ordinal reference_type
  end
end
