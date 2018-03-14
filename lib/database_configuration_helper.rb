require 'hashie/mash'
class DatabaseConfigurationHelper

  def self.database_config
    @database_config ||= DatabaseConfigurationLoader.config
  end

  def self.legacy_database_names_with_suffix(rails_environment)
    database_config_hashes = database_config[rails_environment].values
    legacy_database_config_hashes = database_config_hashes.select do |config|
      config.is_a?(Hash) && config['legacy'] == true
    end
    legacy_database_config_hashes.map{ |hash| hash['database'] }.uniq
  end

  def self.database_config_for(database, rails_environment)
    database_config_hashes = database_config[rails_environment].values
    database_config = database_config_hashes.find do |config|
      config.is_a?(Hash) && config['database'] == database
    end
    database_config
  end

  def self.all_dbs_for_rw_connections(rails_environment)
    database_config[rails_environment].each_with_object([]) do |(key, value), dbs|
      dbs << value['database'] if key['_rw'] && value.is_a?(Hash) && value['database']
    end
  end

  def self.legacy_database_names(rails_environment)
    legacy_database_names_with_suffix = self.legacy_database_names_with_suffix(rails_environment)
    legacy_database_names_with_suffix.map { |name| name.sub "_#{rails_environment}", '' }
  end

  # 
  # Gets a hash of mysql connection details(host, username, password, etc)
  # @param  server [String] The server, e.g. dev, localhost
  # @param  read_only = true [Boolean] Set to false for read-write access
  #
  # @return [Hashie::Mash] A Hash of details that can be accessed via dot
  #                        notation
  def self.server_config_for(server, read_only = true)
    mysql_config_name = 'mysql_' + server
    mysql_config_name = mysql_config_name.to_sym

    self.hashie_of_mysql_connection_info mysql_config_name, read_only
  end

  # 
  # Gets a hash of mysql connection details(host, username, password, etc)
  # @param  mysql_config_name [Symbol] A symbol that exists in database.yml
  # @param  read_only = true [Boolean] Set to false for read-write access
  # 
  # @return [Hashie::Mash] A Hash of details that can be accessed via dot
  #                        notation
  def self.hashie_of_mysql_connection_info(mysql_config_name, read_only = true)
    config_key = mysql_config_name.to_s # don't modify input string
    config_key << '_rw' unless read_only
    Hashie::Mash.new database_config[config_key]
  end

end
