# An Assessment represents the scores of the independent assessment that
# countries can run. It can be of any type, but the known ones are jee1, jee2,
# and spar_2018.
class Assessment < ApplicationRecord
  include AssessmentSeed
end
