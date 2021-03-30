class Disease < ApplicationRecord
  include DiseaseSeed

  has_many :benchmark_indicator_actions

  def self.influenza
    find_by(name: "influenza")
  end

  def self.cholera
    find_by(name: "cholera")
  end

  def self.ebola
    find_by(name: "ebola")
  end

  def attributes
    { id: nil, name: nil, display: nil }
  end
end
