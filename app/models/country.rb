class Country < ApplicationRecord
  include CountrySeed

  has_many :assessments, inverse_of: :country
  has_many :plans

  default_scope { order(:name) }
end
