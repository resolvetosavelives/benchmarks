class Disease < ApplicationRecord
  include DiseaseSeed

  has_many :benchmark_indicator_actions

  scope :influenza, -> { find_by_name("influenza") }
  scope :cholera, -> { find_by_name("cholera") }

  def attributes
    {
        id: nil,
        name: nil,
        display: nil,
    }
  end
end
