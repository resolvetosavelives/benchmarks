namespace :update do
  desc "Update SPAR values from XLS in data/spar/"
  task :spar do
    extend AssessmentSeed::ClassMethods
    seed_spar "spar_2018",
      "data/spar/SPAR Data 2018_2019July9.xlsx",
      "data/spar/SPAR Data 2019_2021Mar29.xlsx",
      update: true
  end
end
