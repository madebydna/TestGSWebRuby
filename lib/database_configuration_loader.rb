require 'states'
require File.expand_path('../../config/initializers/extensions/hash.rb', __FILE__)

class DatabaseConfigurationLoader
  config_folder = File.join(File.dirname(__FILE__), '..', 'config')

  STATE_TEMPLATE_STRING = '_STATE_'

  DEFAULT_FILE = File.join(config_folder, 'database.yml')
  OVERRIDES = [
      File.join('', 'usr', 'local', 'etc', 'GSWebRuby-database.yml'),
      File.join(config_folder, 'database_local.yml'),
  ]

  def self.joined_files
    content = ''
    content << File.read(DEFAULT_FILE) if File.exist? DEFAULT_FILE
    OVERRIDES.each do |override|
      content << File.read(override) if File.exist? override
    end
    return content
  end

  def self.config
    config = YAML.load(ERB.new(joined_files.to_s).result)
    config = expand_state_template_in_config config

    # Hack until Greg and I decide on something better. Allow admin to write to config only on these servers
    if defined?(ENV_GLOBAL) && ENV_GLOBAL['app_host'].match(/(omega\.|dev\.|qa.)/)
      rw_config = config["mysql_#{Rails.env}_rw"]
      if rw_config && config[Rails.env]['profile_config']
        config[Rails.env]['profile_config'].merge! rw_config
      end
    end

    self.overwrite_connection_credentials_if_available(config['development'])
    self.overwrite_test_connection_credentials_if_available(config['test'])

    return config
  end

  # Note this does not distinguish between rw/ro connections
  def self.overwrite_connection_credentials_if_available(config)
    db_host = ENV['db_host'] || ENV_GLOBAL['db_host']
    db_username = ENV['db_username'] || ENV_GLOBAL['db_username']
    db_password = ENV['db_password'] || ENV_GLOBAL['db_password']
    db_read_timeout = (ENV['db_read_timeout'] || ENV_GLOBAL['db_read_timeout'] || 20).to_i
    db_write_timeout = (ENV['db_write_timeout'] || ENV_GLOBAL['db_write_timeout'] || 20).to_i
    db_connect_timeout = (ENV['db_connect_timeout'] || ENV_GLOBAL['db_connect_timeout'] || 5).to_i

    if db_host.present?
      config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = db_host if key == 'host' && hash['database'] != 'gsdata'
      end
    end
    if db_username.present?
      config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = db_username if key == 'username' && hash['database'] != 'gsdata'
      end
    end
    if db_password.present?
      config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = db_password if key == 'password' && hash['database'] != 'gsdata'
      end
    end
    config.gs_recursive_each_with_clone do |hash, key, _|
      hash[key] = db_read_timeout    if key == 'read_timeout'    && db_read_timeout    > 0
      hash[key] = db_write_timeout   if key == 'write_timeout'   && db_write_timeout   > 0
      hash[key] = db_connect_timeout if key == 'connect_timeout' && db_connect_timeout > 0
    end

    gsdata_db_host = ENV['gsdata_db_host'] || ENV_GLOBAL['gsdata_db_host']
    gsdata_db_username = ENV['gsdata_db_username'] || ENV_GLOBAL['gsdata_db_username']
    gsdata_db_password = ENV['gsdata_db_password'] || ENV_GLOBAL['gsdata_db_password']
    gsdata_config = config['gsdata']
    config['gsdata_rw'] ||= config['gsdata']


    if gsdata_db_host.present?
      gsdata_config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = gsdata_db_host if key == 'host'
      end
    end
    if gsdata_db_username.present?
      gsdata_config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = gsdata_db_username if key == 'username'
      end
    end
    if gsdata_db_password.present?
      gsdata_config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = gsdata_db_password if key == 'password'
      end
    end
  end

  def self.overwrite_test_connection_credentials_if_available(config)
    db_host = ENV['test_db_host'] || ENV_GLOBAL['test_db_host']
    db_username = ENV['test_db_username'] || ENV_GLOBAL['test_db_username']
    db_password = ENV['test_db_password'] || ENV_GLOBAL['test_db_password']
    gsdata_db_host = db_host
    gsdata_db_username = db_username
    gsdata_db_password = db_password

    if db_host.present?
      config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = db_host if key == 'host' && hash['database'] != 'gsdata'
      end
    end
    if db_username.present?
      config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = db_username if key == 'username' && hash['database'] != 'gsdata'
      end
    end
    if db_password.present?
      config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = db_password if key == 'password' && hash['database'] != 'gsdata'
      end
    end

    gsdata_config = config['gsdata']
    config['gsdata_rw'] ||= config['gsdata']

    if gsdata_db_host.present?
      gsdata_config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = gsdata_db_host if key == 'host'
      end
    end
    if gsdata_db_username.present?
      gsdata_config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = gsdata_db_username if key == 'username'
      end
    end
    if gsdata_db_password.present?
      gsdata_config.gs_recursive_each_with_clone do |hash, key, value|
        hash[key] = gsdata_db_password if key == 'password'
      end
    end
  end

  def self.expand_state_template_in_config(config)

    config.gs_recursive_each_with_clone do |hash, key, val|
      if key.match STATE_TEMPLATE_STRING
        States.abbreviations.map(&:downcase).each do |state|
          new_key = key.sub STATE_TEMPLATE_STRING, state
          hash[new_key] = val.nil? ? nil : val.clone

          if hash[new_key]
            hash[new_key].gs_recursive_each_with_clone do |hash, key, val|
              if key.match STATE_TEMPLATE_STRING
                hash[key.sub STATE_TEMPLATE_STRING, state] = val
              end
              if val.is_a?(String) && val.match(STATE_TEMPLATE_STRING)
                hash[key] = val.sub STATE_TEMPLATE_STRING, state
              end
            end
          end
        end

        hash.delete key
      end
    end
  end

end
