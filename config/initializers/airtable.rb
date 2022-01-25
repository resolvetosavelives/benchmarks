if Rails.env.production? && !Rails.application.config.asset_compilation
  Airrecord.api_key = Rails.application.credentials.airtable_api_key!
else
  Airrecord.api_key = Rails.application.credentials.airtable_api_key
end
