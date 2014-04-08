require 'database_tasks_helper'
require 'database_configuration_helper'

namespace :db do
  $mysql_dev = Rails.application.config.database_configuration['mysql_dev']

  def environments
    environments = [Rails.env]
    environments << 'test' if Rails.env.development?
  end

  task :reset, [:specific_dbs] => [:drop, :create, :migrate, :seed]

  desc 'Legacy databases and tables are those that already existed. Rake tasks for legacy databases and tables.
  All the legacy databases and the contained tables are hardcoded in a hash in the legacy_database_tasks.rb.
  By defaults the tasks below are performed for all databases.Instead of all the databases, you can just seed one specific database.'

  #Steps for a new legacy database or tables:- The database should be specified in the database.yml file and the
  #legacy table should be specified in the legacy_database_tasks.rb file

  namespace :legacy do

    task :reset, [:specific_dbs] => [:drop, :create, :schema, :seed]

    desc 'Creates seeds by doing a mysql dump from dev for the development and test databases.'
    task :seed, [:specific_dbs] do |task, args|

      #Check if a specific database was passed in the argument list
      $specific_dbs = String(args[:specific_dbs]).split ','

        DatabaseTasksHelper.databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
          if $specific_dbs.empty? || $specific_dbs.include?(db)
            DatabaseTasksHelper.tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|

              #copy_table_schema_from_server mysql_dev, db, table
              DatabaseTasksHelper.copy_data_from_server $mysql_dev, db, table
            end
          end
        end
    end

    desc 'Copies db schemas from dev to localhost (empty without tables) in \
database.yml. First parameter is [overwrite]. If true, will drop databases \
and recreate them. Second parameter is a list of databases to use, comma \
separated. e.g. rake db:legacy:schema[true,_ak,_az,_me]'
    task :schema, [:overwrite] do |task, args|
      $specific_dbs = args.extras
      # Needed to gracefully handle ruby invoking via ruby or via command line
      $overwrite = "#{args[:overwrite]}" == 'true'

      unless $specific_dbs.present?
        $specific_dbs = 
        DatabaseConfigurationHelper.legacy_database_names(Rails.env)
      end

      DatabaseTasksHelper.copy_database_schemas_from_server :mysql_dev, 
                                                            :mysql_localhost, 
                                                            $specific_dbs, 
                                                            $overwrite
    end

    desc 'Creates legacy databases on localhost (empty without tables) in \
database.yml. First parameter is [overwrite]. If true, will drop databases \
and recreate them. Second parameter is a list of databases to use, comma \
separated. e.g. rake db:legacy:create[true,_ak,_az,_me]'
    task :create, [:overwrite] => [:load_config, :rails_env ] do |task, args|
      $specific_dbs = args.extras
      $overwrite = args[:overwrite] == 'true'

      unless $specific_dbs.present?
        $specific_dbs = 
        DatabaseConfigurationHelper.legacy_database_names(Rails.env)
      end

      $specific_dbs.each do |db|
        DatabaseTasksHelper.create_database :mysql_localhost, db, $overwrite
      end
    end

    desc 'Drops the legacy databases and the tables inside them. Fist \
parameter is a list of databases to use, comma separated. e.g. \
rake db:legacy:drop[_ak,_az,_me]'
    task :drop => [:load_config, :rails_env] do |task, args|
      $specific_dbs = args.extras

      unless $specific_dbs.present?
        $specific_dbs = 
        DatabaseConfigurationHelper.legacy_database_names(Rails.env)
      end

      $specific_dbs.each do |db|
        DatabaseTasksHelper.drop_database :mysql_localhost, db
      end
    end
  end
end

task :use_standard_connection do
  ActiveRecord::Base.establish_connection
end


