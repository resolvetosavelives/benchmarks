module Airtable
  def self.client
    @client ||=
      begin
        key = ENV.fetch("AIRTABLE_API_KEY")
        client = Airtable::Client.new(key)
      end
  end

  def self.reference_documents
    @reference_documents ||=
      client.table("tblJxOZGxd8HWE1qs", "Reference Documents")
  end
end
