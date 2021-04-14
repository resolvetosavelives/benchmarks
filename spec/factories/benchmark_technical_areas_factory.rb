FactoryBot.define do
  factory(:benchmark_technical_area) do
    add_attribute(:sequence) { 5 }
    text { "Some text about the technical area" }
  end
end
