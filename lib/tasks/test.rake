namespace :test do
  task :js do
    sh 'yarn test'
  end

  desc "Runs all the tests that CI does: rake test, rake test:system, rake test:js"
  task ci: :environment do
    Rake::Task["test"].invoke
    Rake::Task["test:system"].invoke
    Rake::Task["test:js"].invoke
  end
end

namespace :db do
  namespace :test do
    # this is needed so that Benchmark seed data is populated in the test db
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end
