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
    # jsbundling-rails adds javascript:build to test:prepare. Without testUnit,
    # we must add it ourselves. I'm adding it only to system specs to avoid
    # building webpack before running specs that don't use it.
    desc "Run system specs"
    RSpec::Core::RakeTask.new(system: %w[javascript:build spec:prepare]) do |t|
      t.pattern = 'spec/system/**/*_spec.rb'
    end

    desc "Runs javascript tests"
    task :js do
      sh "yarn test"
    end

    desc "Run all specs"
    task all: %w[spec spec:system]

    desc "Runs CI specs (spec:all spec:js)"
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
