require 'hashie/mash'
class DatabaseConfigurationHelper

  def self.legacy_database_names_with_suffix(rails_environment)
    database_config_hashes = ActiveRecord::Base.configurations[rails_environment].values
    legacy_database_config_hashes = database_config_hashes.select do |config|
      config.is_a?(Hash) && config['legacy'] == true
    end
    legacy_database_config_hashes.map{ |hash| hash['database'] }.uniq
  end

  def self.database_config_for(database, rails_environment)
    database_config_hashes = ActiveRecord::Base.configurations[rails_environment].values
    database_config = database_config_hashes.select do |config|
      config.is_a?(Hash) && config['database'] == database
    end.first
    database_config
  end

  def self.all_connections_for(rails_environment)
    database_config_hashes = ActiveRecord::Base.configurations[rails_environment].select do |key, value|
      value.is_a?(Hash) && value['database']
    end

    database_config_hashes.map { |key, _| key }
  end

  def self.all_rw_connections_for(rails_environment)
    all_connections_for(rails_environment).select { |connection| connection[-3..-1] != '_ro' }
  end

  def self.legacy_database_names(rails_environment)
    legacy_database_names_with_suffix = self.legacy_database_names_with_suffix(rails_environment)
    legacy_database_names_with_suffix.map { |name| name.sub "_#{rails_environment}", '' }
  end

  # Returns Hashie::Mash object that can be used to look up properties using dot notation
  def self.server_config_for(server, read_only = true)
    config_key = 'mysql_' + server
    config_key << '_rw' unless read_only
    Hashie::Mash.new ActiveRecord::Base.configurations[config_key]
  end

end