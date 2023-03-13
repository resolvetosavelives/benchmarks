module Airtable
  class ReferenceLibraryDocument < Airrecord::Table
    self.base_key = "appD3gX9b3YbXUlj1"
    self.table_name = "Form"

    def self.fetch_approved
      self.all(view: "Approved")
    end

    def to_attrs
      {
        airtable_id: self.id,
        author: self["Author"],
        date: self["Publication Date"],
        description: self["Description"],
        last_modified: self["Last Modified"],
        reference_type: self["Document Type"],
        relevant_pages: self["Relevant Pages"],
        technical_areas: self["Technical Areas"],
        thumbnail_url:
          self["Attachments"]&.first&.dig("thumbnails", "large", "url"),
        title: self["Document Title"],
        benchmark_indicator_actions:
          indicators.map do |i|
            i["Activity"].tr("\n", " ").gsub("(Flu) ", "").freeze
          end,
        url: self["URL"]
      }
    end

    has_many :indicators, class: "Airtable::Indicator", column: "Indicator"
  end
end
