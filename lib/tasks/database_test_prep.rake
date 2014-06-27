namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'
    task :prepare_all_dbs => "db:load_config" do
      require_relative '../database_configuration_helper'
      require_relative '../database_tasks_helper'
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'

      DatabaseTasksHelper.copy_database_schemas_from_server(
        :mysql_dev,
        :mysql_localhost,
        legacy_database_names
      ) { |db_name| "#{db_name}_test" }
    end

    # Example of use: rake db=gscms_pub db:test:prepare_db
    task :prepare_db => "db:load_config" do
      source_db = ENV['db']
      destination_db = "#{source_db}_test"

      require_relative '../database_configuration_helper'
      require_relative '../database_tasks_helper'
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'

      DatabaseTasksHelper.copy_database_schema_from_server(
        :mysql_dev,
        :mysql_localhost,
        source_db,
        destination_db,
        true
      )
    end
  end
end
