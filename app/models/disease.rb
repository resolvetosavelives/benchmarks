class Disease < ApplicationRecord
  include DiseaseSeed

  has_many :benchmark_indicator_actions

  scope :influenza, -> { find_by_name("influenza") }

  def attributes
    {
        id: nil,
        name: nil,
        display: nil,
    }
  end
end
