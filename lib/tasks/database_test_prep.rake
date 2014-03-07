namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'
    task :prepare => "db:load_config" do
      require_relative '../database_configuration_helper'
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'
      source_mysql_config = DatabaseConfigurationHelper.server_config_for 'dev'
      destination_mysql_config = DatabaseConfigurationHelper.server_config_for 'localhost'

      legacy_database_names.each do |db_name|

        mysql_destination_string = "mysql -h#{destination_mysql_config.host} -u#{destination_mysql_config.username}"
        if destination_mysql_config.password.present?
          mysql_destination_string << " -p#{destination_mysql_config.password}"
        end

        create_db_command = "echo 'create database #{db_name}_test' | " + mysql_destination_string

        dump_db_command = "mysqldump -d -h#{source_mysql_config.host} -u#{source_mysql_config.username} -p#{source_mysql_config.password} #{db_name} "
        dump_db_command << " | #{mysql_destination_string}"
        dump_db_command << " -D#{db_name}_test"

        puts "Creating database: #{db_name}_test"
        unless system(create_db_command)
          puts 'Skipping create database (it might already exist.) Continuing on.'
        end
        puts "Dumping schema only from #{db_name} to #{db_name}_test with command: #{dump_db_command}"
        system dump_db_command
      end
    end
  end
end
