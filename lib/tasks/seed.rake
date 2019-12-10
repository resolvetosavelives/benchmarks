namespace :db do

  namespace :seed do

    desc "Delete records for the seedable models (won't work if there are plan-related records referencing these"
    task delete: :environment do
      ApplicationRecord::SEEDABLE_MODELS.reverse.each do |model_class|
        begin
          ActiveSupport::Inflector.constantize(model_class).unseed!
        rescue ActiveRecord::InvalidForeignKey => ifk
          $stderr.puts ""
          $stderr.puts "Not able to delete data for #{model_class}, probably because there is plan data that depends on it. Exception follows..".yellow.on_black
          $stderr.puts ""
          raise ifk
        end
      end
    end

    desc "Delete records for the seedable models and then re-seed"
    task redo: :delete do
      Rake::Task["db:seed"].invoke
    end

  end

end
