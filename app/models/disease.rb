class Disease < ApplicationRecord
  include DiseaseSeed

  has_many :benchmark_indicator_actions

  scope :influenza, -> { find_by_name("influenza") }
end
