FactoryBot.define do
  factory :benchmark_indicator do
    benchmark_technical_area
    add_attribute(:sequence) { 1 }
    display_abbreviation { "hello" }
    text { "Something long about the indicator" }
    objective { "Be really good" }
  end
end
