def monkey_patch_database_cleaner
  DatabaseCleaner::ActiveRecord::Base.module_eval do
    # For some reason, by default database_cleaner will re-load the database.yml file, but we modify
    # Rails' db configuration after database.yml is loaded by the Rails environment.
    #
    # Instead of letting database_cleaner reload database.yml, just tell it to use the config that is already loaded
    def load_config
      if self.db != :default && self.db.is_a?(Symbol)
        @connection_hash = ::ActiveRecord::Base.configurations['test'][self.db.to_s]
      end
    end
  end
end

# Takes as arguments as list of db names as symbols
def clean_dbs(*args)
  args.each do |db|
    DatabaseCleaner[:active_record, connection: "#{db}_rw".to_sym].strategy = :truncation
    DatabaseCleaner[:active_record, connection: "#{db}_rw".to_sym].clean
    disconnect_connection_pools(db)
  end
end

def clean_models(db, *models)
  unless db.is_a? Symbol
    models = [ db ] + models
    db = nil
  end

  models.each do |model|
    if db
      db_name = db.to_s
      db_name = "_#{db_name}" if States.abbreviations.include?(db_name)
      db_name << '_test'
      model.connection.execute("TRUNCATE #{db_name}.#{model.table_name}")
      disconnect_connection_pools(db_name.sub('_test', ''))
    else
      model.destroy_all
    end
  end
end