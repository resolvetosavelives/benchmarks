Airrecord.api_key = ENV.fetch("AIRTABLE_API_KEY")

module Airtable
  class ReferenceLibraryDocuments < Airrecord::Table
    self.base_key = "appD3gX9b3YbXUlj1"
    self.table_name = "Form"

    def self.fetch_approved(since: nil)
      filter = "IS_AFTER(LAST_MODIFIED_TIME(), #{since.utc.iso8601})" if since
      self.all(view: "Approved", filter: filter)
    end

    def to_attrs
      attachment = self["Attachments"].first

      {
        title: self["Document Title"],
        description: self["Description"],
        author: self["Author"],
        date: self["Publication Date"],
        relevant_pages: self["Relevant Pages"],
        technical_area: self["Technical Area"],
        document_type: self["Document Type"],
        download_url: attachment & ["url"],
        thumbnail_url: attachment & ["thumbnails"] & ["large"] & ["url"],
        url: self["URL"],
        last_modified: self["Last Modified"]
      }
    end
  end
end
