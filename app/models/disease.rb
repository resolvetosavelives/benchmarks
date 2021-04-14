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

  def as_json(options = {})
    super(options.reverse_merge(only: %i[id name display]))
  end
end
