begin
  require 'rspec/core/rake_task'

  # redefine the default task to exclude system specs that are much slower
  Rake::Task[:spec].clear
  Rake::Task[:default].clear

  task :default => :spec

  desc "Run all specs except system specs"
  RSpec::Core::RakeTask.new(spec: "spec:prepare") do |t|
    t.exclude_pattern = 'spec/system/**/*_spec.rb'
  end

  namespace :spec do
    desc "Run all specs"
    RSpec::Core::RakeTask.new(all: "spec:prepare")

    desc "Runs javascript tests"
    task :js do
      sh "yarn test"
    end

    desc "Runs CI specs (spec:all, spec:js)"
    task ci: %w[spec:all spec:js]
  end
rescue LoadError
  # no rspec available
end

namespace :db do
  namespace :test do
    # this is needed so that Benchmark seed data is populated in the test db
    task prepare: :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end
