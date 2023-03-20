namespace :update do
  desc "Update SPAR values from XLS in data/spar/"
  task :spar do
    extend AssessmentSeed::ClassMethods
    seed_spar "data/spar/SPAR Data 2018_2019July9.xlsx",
              "data/spar/SPAR Data 2019_2021Mar29.xlsx",
              update: true
  end

  desc "Update JEE v1 and v2 values from RTSL master table in data/"
  task :jee do
    extend AssessmentSeed::ClassMethods
    seed_jee "data/JEE scores Mar 2021.xlsx", update: true
  end

  desc "Update Reference Library Documents from Airtable"
  task reference_documents: :environment do
    Rails.logger = ActiveRecord::Base.logger = Logger.new(STDOUT)
    Rails.logger.level = :info
    ReferenceLibraryDocument.update_from_airtable!
  end
end
