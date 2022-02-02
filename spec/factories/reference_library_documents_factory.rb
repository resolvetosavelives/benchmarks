FactoryBot.define do
  factory(:reference_library_document) do
    sequence(:download_url) { |n| "https://example.com/document#{n}.pdf" }
  end
end
