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

def clean_chosen_models
  @db_clean_commands ||= Hash.new { |h, k| h[k] = [] }
  @db_clean_commands[:clean_models].each do |command|
    do_clean_models(*command)
  end
  @db_clean_commands[:clean_models] = []
end

def clean_chosen_dbs
  @db_clean_commands ||= Hash.new { |h, k| h[k] = [] }
  @db_clean_commands[:clean_dbs].each do |command|
    do_clean_dbs(*command)
  end
  @db_clean_commands[:clean_dbs] = []
end

# Takes as arguments as list of db names as symbols
def clean_dbs(*args)
  @db_clean_commands ||= Hash.new { |h, k| h[k] = [] }
  @db_clean_commands[:clean_dbs] << args
end

def clean_models(*args)
  @db_clean_commands ||= Hash.new { |h, k| h[k] = [] }
  @db_clean_commands[:clean_models] << args
end

def do_clean_dbs(*dbs)
  dbs.each do |db|
    db_name = db.to_s
    db_name = "_#{db_name}" if States.abbreviations.include?(db_name)
    db_name << '_test'
    ActiveRecord::Base.connection.execute("show tables in #{db_name}").to_a.flatten.each do |table_name|
      ActiveRecord::Base.connection.execute("TRUNCATE table #{db_name}.#{table_name}")
    end
  end
end

def do_clean_models(db, *models)
  unless db.is_a? Symbol
    models = [ db ] + models
    db = nil
  end

  models.each do |model|
    if db
      db_name = db.to_s
      db_name = "_#{db_name}" if States.abbreviations.include?(db_name)
      db_name << '_test'
      model.connection.execute("TRUNCATE table #{db_name}.#{model.table_name}")
    else
      model.destroy_all
    end
  end
end
