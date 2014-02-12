require 'states'
require Rails.root.join('config', 'initializers', 'extensions', 'hash.rb')
class DatabaseConfigurationLoader

  STATE_TEMPLATE_STRING = '_STATE_'

  DEFAULT_FILE = Rails.root.join('config', 'database.yml')
  OVERRIDES = [
      File.join('', 'usr', 'local', 'etc', 'GSWebRuby-database.yml'),
      Rails.root.join('config', 'database-local.yml'),
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
    return config
  end

  def self.expand_state_template_in_config(config)

    config.gs_recursive_each_with_clone do |hash, key, val|
      if key.match STATE_TEMPLATE_STRING
        States.abbreviations.each do |state|
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