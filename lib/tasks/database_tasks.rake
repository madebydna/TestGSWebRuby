require 'states'
require 'legacy_database_tasks'

namespace :db do
  $mysql_dev = Rails.application.config.database_configuration['mysql_dev']

  def environments
    # logic taken from railties databases.rake
    environments = [Rails.env]
    #environments << 'test' if Rails.env.development?
  end

  task :reset, [:specific_dbs] => [:drop, :create, :migrate]

  namespace :legacy do
    task :load_schema_and_seed  do |task, args|
      create_tables_and_seeds
    end

    desc 'Create state and gs_schooldb dev and test dbs on dev workstations.'
    task :create, [:specific_dbs] => [:load_config, :rails_env] do |task, args|

      config = (ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['host'].blank? }).first.clone



      $specific_dbs = String(args[:specific_dbs]).split ','
      environments.each do |env|
        LegacyDatabaseTasks.all_legacy_dbs.each do |db|
          if $specific_dbs.empty? || $specific_dbs.include?(db)
            puts "Creating #{env} database #{db} on #{config['host']}"

            # not currently using the current environment within the db name. this may change
            # i.e. for test env we might create "_ca_test" for california
            config['database'] = db

            create_database config
          end
        end
      end

      LegacyDatabaseTasks.databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
        if $specific_dbs.empty? || $specific_dbs.include?(db)
          LegacyDatabaseTasks.tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|

            LegacyDatabaseTasks.copy_table_schema_from_server $mysql_dev, db, table
          end
        end
      end

    end

    task :drop, [:specific_dbs] => [:load_config, :rails_env] do |task, args|

      ActiveRecord::Base.configurations.each_value do  |config|
        #puts "--config----------------#{config}---------"
        #puts "--2----------------#{config['database']}---------"
        #config.each do |key,value|
        #  puts "--f---------------#{key}---------"
        #  puts "---g---------------#{value}---------"
        #end
      end
      #config = (ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['database'].blank? }).first.clone
      config = (ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['host'].blank? }).first.clone

      $specific_dbs = String(args[:specific_dbs]).split ','



      environments.each do |env|
        LegacyDatabaseTasks.all_legacy_dbs.each do |db|
          if $specific_dbs.empty? || $specific_dbs.include?(db)

            puts "Dropping #{env} database #{db} on #{config['host']}"

            config['database'] = db
            drop_database_and_rescue config
          end
        end
      end
    end

  end
end


task :use_standard_connection do
  ActiveRecord::Base.establish_connection
end

