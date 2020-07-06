class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ##
  # This constant +SEEDABLE_MODELS+ is intended to streamline and simplify the
  # process of seeding and unseeding the database with the base data. It serves
  # that purpose now but does have some complications, namely that foreign keys
  # in the DB can make it finicky about the order in which data is deleted. This
  # is dealt with for now by reversing the order and deleting data via SQL
  # statement of DELETE ... CASCADE. If this becomes more complicated or blocks
  # other useful things then by all means go ahead and remove it.
  SEEDABLE_MODELS = %w[
    Country
    AssessmentPublication
    AssessmentTechnicalArea
    AssessmentIndicator
    Assessment
    BenchmarkTechnicalArea
    BenchmarkIndicator
    BenchmarkIndicatorAction
    Disease
  ]
end
