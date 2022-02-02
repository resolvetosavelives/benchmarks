FactoryBot.define do
  factory :country do
    name { "Gensokyo" }
    alpha2 { "GN" }
    alpha3 { "GNS" }
    country_code { "999" }
    region { "Asia" }
    sub_region { "Eastern Asia" }
    intermediate_region { "" }
    region_code { "998" }
    sub_region_code { "997" }
    intermediate_region_code { "" }
  end
end
