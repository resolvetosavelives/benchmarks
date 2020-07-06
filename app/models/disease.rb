class Disease < ApplicationRecord
  include DiseaseSeed
  scope :influenza, -> { find_by_name("influenza") }
end
