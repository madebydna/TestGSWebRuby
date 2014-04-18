#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'config', 'initializers', 'extensions'))
require 'mysql2'
require 'states'
require 'database_configuration_loader'
require 'database_configuration_helper'
require 'database_tasks_helper'
require 'hashie'
require 'active_support/core_ext/string'
require 'yaml'
require 'erb'

class DatabaseTestPrep
  def self.prepare_test_db
    legacy_database_names = DatabaseConfigurationHelper.legacy_database_names 'test'

    DatabaseTasksHelper.copy_database_schemas_from_server(
      :mysql_dev, 
      :mysql_localhost, 
      *legacy_database_names
    ) { |db_name| "#{db_name}_test" }
  end
end

DatabaseTestPrep.prepare_test_db
