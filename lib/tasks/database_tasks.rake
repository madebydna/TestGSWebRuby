require 'legacy_database_tasks'

namespace :db do
  $mysql_dev = Rails.application.config.database_configuration['mysql_dev']

  def environments
    environments = [Rails.env]
    environments << 'test' if Rails.env.development?
  end

  task :reset, [:specific_dbs] => [:drop, :create, :migrate, :seed]

  desc 'Rake tasks for legacy databases and tables.
  All the legacy databases and the contained tables are hardcoded in a hash in the legacy_database_tasks.rb.
  By defaults the tasks below are performed for all databases.Instead of all the databases, you can just seed one specific database.'
  namespace :legacy do

    task :reset, [:specific_dbs] => [:drop, :create, :schema, :seed]

    desc 'Creates seeds by doing a mysql dump from dev for the development and test databases.'
    task :seed, [:specific_dbs] do |task, args|

      #Check if a specific database was passed in the argument list
      $specific_dbs = String(args[:specific_dbs]).split ','

        LegacyDatabaseTasks.databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
          if $specific_dbs.empty? || $specific_dbs.include?(db)
            LegacyDatabaseTasks.tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|

              #copy_table_schema_from_server mysql_dev, db, table
              LegacyDatabaseTasks.copy_data_from_server $mysql_dev, db, table
            end
          end
        end
    end

    desc 'Creates the schema for the tables in development and test databases.It does a mysql dump from dev to obtain the schema. '
    task :schema, [:specific_dbs] do |task, args|

      #Check if a specific database was passed in the argument list
      $specific_dbs = String(args[:specific_dbs]).split ','

      #creates the tables inside the databases for both development and test environment.
      environments.each do |env|
        LegacyDatabaseTasks.databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
          if $specific_dbs.empty? || $specific_dbs.include?(db)

            #If its the _test environment then get the database name appended with "_test"
            database_name = env.eql?("test") ? db + "_test" : db

            LegacyDatabaseTasks.tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|
              LegacyDatabaseTasks.copy_table_schema_from_server $mysql_dev, db, table, database_name
            end
          end
        end
      end
    end


    desc 'Drops and then creates the legacy development and test databases.'
    task :create, [:specific_dbs] => [:load_config, :rails_env, :drop] do |task, args|

      #parse the database configurations in the database.yml file.
      environments.each do |env|
        configs = ActiveRecord::Base.configurations.values_at(env).first.values.select { |value|
          value.is_a?(Hash) && value['legacy'] && !value['database'].blank?
        }

        #Check if a specific database was passed in the argument list
        unless $specific_dbs.nil? || $specific_dbs.empty?
          configs.select { |config| $specific_dbs.detect { |db| config['database'].matches(db) } }
        end

        configs.each do |config|
          database_name = config['database']
          puts "Creating #{env} database #{database_name} on #{config['host']}"
          create_database config
        end
      end
    end


    desc 'Drops the legacy development and test databases and the tables inside them.'
    task :drop, [:specific_dbs] => [:load_config, :rails_env] do |task, args|

      #parse the database configurations in the database.yml file.
      environments.each do |env|
        configs = ActiveRecord::Base.configurations.values_at(env).first.values.select { |value|
          value.is_a?(Hash) && value['legacy'] && !value['database'].blank?
        }

        #Check if a specific database was passed in the argument list
        unless $specific_dbs.nil? || $specific_dbs.empty?
          configs.select { |config| $specific_dbs.include?(config['database']) }
        end

        configs.each do |config|
          database_name = config['database']
          puts "Dropping #{env} database #{database_name} on #{config['host']}"
          drop_database_and_rescue config
        end
      end
    end


  end
end

task :use_standard_connection do
  ActiveRecord::Base.establish_connection
end


