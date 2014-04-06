namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'
    task :prepare => "db:load_config" do
      require 'mysql2'
      require_relative '../database_configuration_helper'
      legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'
      source_mysql_config = DatabaseConfigurationHelper.server_config_for 'dev'
      destination_mysql_config = DatabaseConfigurationHelper.server_config_for 'localhost'

      client = Mysql2::Client.new(host: destination_mysql_config.host, username: destination_mysql_config.username, password: destination_mysql_config.password )

      legacy_database_names.each do |db_name|
        test_db_name = "#{db_name}_test"
        if ! client.query("show databases like '#{test_db_name}'").any?
          mysql_destination_string = "mysql -h#{destination_mysql_config.host} -u#{destination_mysql_config.username}"
          if destination_mysql_config.password.present?
            mysql_destination_string << " -p#{destination_mysql_config.password}"
          end

          create_db_command = "echo 'create database #{test_db_name}' | " + mysql_destination_string

          dump_db_command = "mysqldump -d -h#{source_mysql_config.host} -u#{source_mysql_config.username} -p#{source_mysql_config.password} #{db_name} "
          dump_db_command << " | #{mysql_destination_string}"
          dump_db_command << " -D#{test_db_name}"

          puts "Creating database: #{test_db_name}"
          unless system(create_db_command)
            puts 'Skipping create database (it might already exist.) Continuing on.'
          end
          puts "Dumping schema only from #{db_name} to #{test_db_name} with command: #{dump_db_command}"
          system dump_db_command
        else
          puts "#{test_db_name} already exists, skipping."
        end
      end
    end
  end
end
