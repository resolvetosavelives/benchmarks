Airrecord.api_key =
  if Rails.env.production? && !Rails.application.config.asset_compilation
    ENV.fetch("AIRTABLE_PAT") do
      Rails.application.credentials.airtable_api_key!
    end
  else
    ENV.fetch("AIRTABLE_PAT", Rails.application.credentials.airtable_api_key)
  end
