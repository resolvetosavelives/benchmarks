if Rails.env.production?
  Airrecord.api_key = Rails.application.credentials.airtable_api_key!
else
  Airrecord.api_key = Rails.application.credentials.airtable_api_key
end
