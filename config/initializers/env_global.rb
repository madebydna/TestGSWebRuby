ENV_GLOBAL = YAML.load_file("#{Rails.root}/config/env_global.yml")

file = File.join('', 'usr', 'local', 'etc', 'gsweb-rails-config.yml')

YAML.load_file(file) if File.exist?(file)
