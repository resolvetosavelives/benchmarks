namespace :db do
  namespace :schema do
    desc "Fails if schema is not loaded or connection fails. Returns silently otherwise."
    task loaded: :environment do
      unless ActiveRecord::Base.connection.table_exists?(:schema_migrations)
        raise "Schema not loaded"
      end
    end
  end
end
