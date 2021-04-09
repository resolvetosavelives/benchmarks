module Airtable
  class ReferenceLibraryDocument < Airrecord::Table
    self.base_key = "appD3gX9b3YbXUlj1"
    self.table_name = "Form"

    def self.fetch_approved(since: nil)
      filter = "IS_AFTER(LAST_MODIFIED_TIME(), #{since.utc.iso8601})" if since
      self.all(view: "Approved", filter: filter)
    end

    def to_attrs
      attachment = self["Attachments"].first

      {
        author: self["Author"],
        date: self["Publication Date"],
        description: self["Description"],
        download_url: attachment&.dig("url"),
        last_modified: self["Last Modified"],
        reference_type: self["Document Type"],
        relevant_pages: self["Relevant Pages"],
        technical_area: self["Technical Area"],
        thumbnail_url: attachment&.dig("thumbnails", "large", "url"),
        title: self["Document Title"],
        url: self["URL"]
      }
    end

    has_many :indicators, class: "Airtable::Indicator", column: "Indicator"
  end
end
