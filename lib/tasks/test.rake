namespace :test do
  task :js do
    sh 'yarn test'
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
