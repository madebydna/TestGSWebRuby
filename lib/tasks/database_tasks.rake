require 'states'
require 'octopus'

namespace :db do
  task :reseed => [:drop, :create, :migrate, :seed]

  namespace :shards do
    sharded_tables = %w(school esp_response census_data_set census_data_school_value census_data_district_value census_data_state_value)
    tables = %w(list_member)

    states = States.state_hash.values
    databases = states.map{|state| '_' + state.downcase}

    desc 'Create shards dbs.'
    task :create, [:username, :password, :state] => :load_config do |task, args|
      username = args[:username]
      password = args[:password]
      state = args[:state]

      if state
        databases = Array(state)
      else
        databases << 'LocalizedProfiles_development'
      end

      states.each do |db|
        puts "Creating database #{db}"
        create_database "_#{db}"
      end
    end

    desc 'populate tables in shards dbs with data from dev.'
    task :seed, [:username, :password, :state] => :load_config do |task, args|
      return unless Rails.env == 'development'
      username = args[:username]
      password = args[:password]
      state = args[:state]

      if state
        databases = Array(state)
      else
        databases << 'LocalizedProfiles_development'
      end

      config = ActiveRecord::Base.configurations[Rails.env]

      limit_rows = 10000000

      databases.each do |db|
        source_db = db
        source_db = '_ca' if db == 'LocalizedProfiles_development'
        puts "seeding #{db}"
        sharded_tables.each do |table|
          puts "seeding #{table}"
          sql_command = "mysqldump -uservice -pservice -hdev.greatschools.net --compact --databases \"#{source_db}\" --tables \"#{table}\" --skip-set-charset --no-create-info --skip-comments --where \"1 limit #{limit_rows}\" | tr -d \"\\`\" | mysql -uroot #{db}"
          system(sql_command)
        end
      end
    end

    desc 'create tables in shards dbs'
    task :create_tables, [:username, :password, :state] => :load_config do |task, args|
      return unless Rails.env == 'development'
      username = args[:username]
      password = args[:password]
      state = args[:state]

      if state
        databases = Array(state)
      else
        databases << 'LocalizedProfiles_development'
      end

      limit_rows = 10000

      databases.each do |db|
        source_db = db
        source_db = '_ca' if db == 'LocalizedProfiles_development'
        puts "using #{db}"
        sharded_tables.each do |table|
          puts "creating table #{table} from dev create table info"
          sql_command = "mysqldump -uservice -pservice -hdev.greatschools.net --compact --databases \"#{source_db}\" --tables \"#{table}\" --skip-set-charset --no-data --skip-comments --where \"1 limit #{limit_rows}\" | tr -d \"\\`\" | mysql -u root #{db}"
          system(sql_command)
        end
      end

    end

    desc 'drop tables in shards dbs'
    task :drop_tables, [:username, :password, :state] => :load_config do |task, args|
      return unless Rails.env == 'development'
      state = args[:state]

      if state
        databases = Array(state)
      else
        databases << 'LocalizedProfiles_development'
      end

      databases.each do |db|
        puts "using #{db}"
        sharded_tables.each do |table|
          puts "dropping table #{table} on this machine"
          sql_command = "echo drop table #{db}.#{table} | mysql -uroot"
          system(sql_command)
        end
      end
    end

    task :setup, [:username, :password, :state] => [:drop_tables, :create_tables, :seed]
  end

  namespace :gs_schooldb do
    tables = %w(list_member)
    limit_rows = 10000000
    source_db = 'gs_schooldb'

    task :drop_tables, [:username, :password, :state] => :load_config do |task, args|
      return unless Rails.env == 'development'
      username = args[:username]
      password = args[:password]

      # now create non-shared tables
      tables.each do |table|
        sql_command = "echo drop table #{source_db}.#{table} | mysql -u root #{source_db}"
        system(sql_command)
      end
    end

    task :create_tables, [:username, :password, :state] => :load_config do |task, args|
      return unless Rails.env == 'development'
      username = args[:username]
      password = args[:password]
      source_db = 'gs_schooldb'

      # now create non-shared tables
      tables.each do |table|
        sql_command = "mysqldump -uservice -pservice -hdev.greatschools.net --compact --databases \"#{source_db}\" --tables \"#{table}\" --skip-set-charset --no-data --skip-comments --where \"1 limit #{limit_rows}\" | tr -d \"\\`\" | mysql -u root #{source_db}"
        system(sql_command)
      end
    end

    task :seed, [:username, :password, :state] => :load_config do |task, args|
      tables.each do |table|
        puts "seeding #{table}"
        sql_command = "mysqldump -uservice -pservice -hdev.greatschools.net --compact --databases \"#{source_db}\" --tables \"#{table}\" --skip-set-charset --no-create-info --skip-comments --where \"1 limit #{limit_rows}\" | tr -d \"\\`\" | mysql -uroot #{source_db}"
        system(sql_command)
      end
    end

  end
end

