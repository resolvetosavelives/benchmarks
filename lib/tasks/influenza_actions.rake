namespace :diseases do
  desc "Insert records for Influenza Actions into the database (for Staging and Production)"
  task influenza: :environment do
    BenchmarkIndicatorAction.seed_influenza_actions!
  end
end
