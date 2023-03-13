FactoryBot.define do
  factory(:reference_library_document) do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentences.join(" ") }
    airtable_id { Faker::Alphanumeric.alphanumeric(number: 17) }
  end
end
