#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'config', 'initializers', 'extensions'))
require 'mysql2'
require 'states'
require 'database_configuration_loader'
require 'hashie'
require 'active_support/core_ext/string'
require 'yaml'
require 'erb'

class DatabaseTestPrep
  def self.config
    DatabaseConfigurationLoader.config
  end

  def self.legacy_database_names_with_suffix(rails_environment)
    database_config_hashes = config[rails_environment].values
    legacy_database_config_hashes = database_config_hashes.select do |config|
      config.is_a?(Hash) && config['legacy'] == true
    end
    legacy_database_config_hashes.map{ |hash| hash['database'] }.uniq
  end

  def self.database_config_for(database, rails_environment)
    database_config_hashes = config[rails_environment].values
    database_config = database_config_hashes.select do |config|
      config.is_a?(Hash) && config['database'] == database
    end.first
    database_config
  end

  def self.all_connections_for(rails_environment)
    database_config_hashes = config[rails_environment].select do |key, value|
      value.is_a?(Hash) && value['database']
    end

    database_config_hashes.map { |key, _| key }
  end

  def self.all_rw_connections_for(rails_environment)
    all_connections_for(rails_environment).select { |connection| connection[-3..-1] == '_rw' }
  end

  def self.legacy_database_names(rails_environment)
    legacy_database_names_with_suffix = self.legacy_database_names_with_suffix(rails_environment)
    legacy_database_names_with_suffix.map { |name| name.sub "_#{rails_environment}", '' }
  end

  # Returns Hashie::Mash object that can be used to look up properties using dot notation
  def self.server_config_for(server, read_only = true)
    config_key = 'mysql_' + server
    config_key << '_rw' unless read_only
    Hashie::Mash.new config[config_key]
  end

  def self.prepare_test_db
    legacy_database_names = legacy_database_names 'test'
    source_mysql_config = server_config_for 'dev'
    destination_mysql_config = server_config_for 'localhost'

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

DatabaseTestPrep.prepare_test_db
