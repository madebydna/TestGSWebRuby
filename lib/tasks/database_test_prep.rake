namespace :db do
  namespace :test do
    desc 'Create the legacy test databases'
    task :prepare => "db:load_config" do

      make_test_versions_of_dbs = [
        :gs_schooldb, :community
      ]

      database_configs = ActiveRecord::Base.configurations.values_at(Rails.env).first

      make_test_versions_of_dbs.each do |db|
        db = db.to_s
        config = database_configs[db]
        username = config['username']
        password = config['password']
        if password.present?
          command = "mysqldump -u#{username} -p#{password} -d #{db} | mysql -u#{username} -p#{password} -D#{db}_test"
        else
          command = "mysqldump -u#{username} -d #{db} | mysql -u#{username} -D#{db}_test"
        end
        puts "db:test:prepare copying #{db} to #{db}_test with command: #{command}"
        system command
      end

    end
  end
end
