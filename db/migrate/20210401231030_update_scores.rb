class UpdateScores < ActiveRecord::Migration[6.1]
  include AssessmentSeed::ClassMethods

  def change
    update_spar "data/spar/SPAR Data 2018_2019July9.xlsx",
                "data/spar/SPAR Data 2019_2021Mar29.xlsx"
    update_jee "data/JEE scores Mar 2021.xlsx"
  end
end
