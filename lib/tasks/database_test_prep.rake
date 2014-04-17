namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'
    task :prepare => "db:load_config" do
      require_relative '../database_configuration_helper'
      require_relative '../database_tasks_helper'
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'

      require 'debugger'; debugger

      DatabaseTasksHelper.copy_database_schemas_from_server(
        :mysql_dev,
        :mysql_localhost,
        legacy_database_names
      ) { |db_name| "#{db_name}_test" }

    end
  end
end
