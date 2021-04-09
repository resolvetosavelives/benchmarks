if Rails.env.production?
  Airrecord.api_key = ENV.fetch("AIRTABLE_API_KEY")
else
  Airrecord.api_key = ENV["AIRTABLE_API_KEY"]
end
