namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'
    task :prepare => "db:load_config" do

      # The symbols in this array need to match the keys in database.yml.
      # In other words, they might not match the actual database name you want to copy
      make_test_versions_of_dbs = [
        :gs_schooldb, :community, :ca
      ]

      database_configs = ActiveRecord::Base.configurations.values_at(Rails.env).first

      make_test_versions_of_dbs.each do |db_config_key|
        db_config_key = db_config_key.to_s
        config = database_configs[db_config_key]
        if config.present?
          username = config['username']
          password = config['password']
          db = config['database']
          if password.present?
            command = "mysqldump -u#{username} -p#{password} -d #{db} | mysql -u#{username} -p#{password} -D#{db}_test"
          else
            command = "mysqldump -u#{username} -d #{db} | mysql -u#{username} -D#{db}_test"
          end
          puts "db:test:prepare copying #{db} to #{db}_test with command: #{command}"
          system command
        else
          puts "Could not find database.yml configuration block for db:  #{db}"
        end
      end

    end
  end
end
