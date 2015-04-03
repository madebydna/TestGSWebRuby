namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'

    # Examples of use
    # rake db:test:prepare_all_dbs overwrite=false
    # rake db:test:prepare_all_dbs overwrite=false source_server=omega
    task :prepare_all_dbs => "db:load_config" do
      require_relative '../database_configuration_helper'
      require_relative '../database_tasks_helper'
      source_server = ENV['source_server'] || :dev
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'
      overwrite = ENV['overwrite']
      overwrite = true if overwrite.nil?

      DatabaseTasksHelper.copy_database_schemas_from_server(
        "mysql_#{source_server}".to_sym,
        :mysql_localhost,
        legacy_database_names,
        overwrite
      ) { |db_name| "#{db_name}_test" }
    end

    # Examples of use
    # rake db:test:prepare_db db=gscms_pub
    # rake db:test:prepare_db db=gscms_pub source_server=omega
    task :prepare_db => "db:load_config" do
      source_db = ENV['db']
      destination_db = "#{source_db}_test"
      source_server = ENV['source_server'] || :dev

      require_relative '../database_configuration_helper'
      require_relative '../database_tasks_helper'
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'

      DatabaseTasksHelper.copy_database_schema_from_server(
        "mysql_#{source_server}".to_sym,
        :mysql_localhost,
        source_db,
        destination_db,
        true
      )
    end
  end
end
