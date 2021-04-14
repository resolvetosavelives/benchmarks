FactoryBot.define do
  factory(:benchmark_indicator_action) do
    benchmark_indicator
    text { "Give cats the vote." }
    level { 4 }
    add_attribute(:sequence) { 1 }
    action_types { [7] }
  end
end
