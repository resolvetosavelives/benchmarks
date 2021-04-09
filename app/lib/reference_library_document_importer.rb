# frozen_string_literal: true

require "csv"

class ReferenceLibraryDocumentImporter
  PATH_TO_CSV_FILE =
    Rails
      .root
      .join("data", "reference_library_documents_from_airtable.csv")
      .freeze

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

  attr_reader :csv_path, :rows

  def initialize(csv_path = PATH_TO_CSV_FILE)
    @csv_path = csv_path
    @rows = CSV.read(csv_path).drop(1)
  end

  def import!(csv = PATH_TO_CSV_FILE)
    record_hashes = rows.map { |row| record_hash_from_row(row) }
    record_hashes.each { |r| ReferenceLibraryDocument.create(r) }
  end

  def record_hash_from_row(row)
    {
      download_url: extract_download_url(row[1]&.strip),
      title: row[2]&.strip,
      description: row[3]&.strip,
      technical_area: row[4]&.strip,
      benchmark_indicator_action_ids: find_indicator_actions(row[5]&.strip),
      reference_type: row[6]&.strip,
      author: row[7]&.strip,
      date: row[8]&.strip,
      relevant_pages: row[11]&.strip,
      thumbnail_url: extract_download_url(row[13]&.strip)
    }
  end

  def extract_download_url(attachments_field)
    return "" if attachments_field.blank?

    # tokenize into an array based on comma. most have one but some have two.
    attachments = attachments_field.split(",")

    # take the last one which was probably the first added
    first_attachment = attachments[attachments.size - 1]

    # pluck out the URL from within the parentheses at the end of this string
    match = first_attachment.match(/.*\((.*)\)\Z/)
    return match[1] if match
  end

  def reference_type_ordinal(reference_type_name)
    index = REFERENCE_TYPES.index(reference_type_name)
    return nil if index.nil?

    index + 1
  end

  def find_indicator_actions(text)
    indicator_texts = CSV.parse(text, quote_char: "\"").first # just one row
    indicator_texts.map do |it|
      words = it.split(" ")
      sequence = words.first
      text = words[1..-1].join(" ")
      BenchmarkIndicatorAction.find_by_text(text)&.id
    end
  end
end
