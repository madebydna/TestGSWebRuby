require 'states'
require 'octopus'

$tables_receiving_mysql_dump = {
    state_tables: %w(
      school
      esp_response
      census_data_set
      census_data_school_value
      census_data_district_value
      census_data_state_value
      TestDataSet
      TestDataStateValue
      TestDataDistrictValue
      TestDataSchoolValue
    ),
    gs_schooldb_tables: %w(
      list_member
      TestDataSetFile
      TestDataBreakdown
      TestDataSubject
      TestDataType
    )
}.stringify_keys!

$state_dbs_receiving_mysql_dump = %w(_ca _dc)

$databases_receiving_mysql_dump = {
    _ca: :state_tables,
    _dc: :state_tables,
    gs_schooldb: :gs_schooldb_tables
}.stringify_keys!

$state_dbs_receiving_mysql_dump.each { |state| $databases_receiving_mysql_dump[state] = :state_tables }

namespace :db do
  state_dbs = %w(_ca _dc)
  other_dbs = %w(gs_schooldb)
  all_legacy_dbs = state_dbs.clone + other_dbs

  def dump_schema_from_dev(source_db, filename = source_db)
    database_config = YAML::load(File.open("#{Rails.root}/config/database.yml"))
    config = database_config['mysql_dev']
    config['database'] = source_db

    filename = "#{Rails.root}/db/#{filename}.rb"
    File.open(filename, 'w:utf-8') do |file|
      ActiveRecord::Base.custom_octopus_connection = true
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  def load_schema(source_db, destination_db, table)
    mysql_dev = Rails.application.config.database_configuration['mysql_dev']

    puts "creating table #{source_db}.#{table} from create table info on #{mysql_dev['host']}"
    sql_command = "mysqldump -uservice -pservice -h#{mysql_dev['host']} --compact --databases \"#{source_db}\" --tables \"#{table}\" --skip-set-charset --no-data --skip-comments | tr -d \"\\`\" | mysql -u root #{destination_db}"
    system(sql_command)
  end

  def environments
    # logic taken from railties databases.rake
    environments = [Rails.env]
    environments << 'test' if Rails.env.development?
  end

  # def load_schema(destination_db, filename)
  #  database_config = YAML::load(File.open("#{Rails.root}/config/database.yml"))
  #
  #  file = "#{Rails.root}/db/#{filename}.rb"
  #
  #  config = database_config['mysql_localhost']
  #  config['database'] = destination_db
  #
  #  ActiveRecord::Base.custom_octopus_connection = true
  #  ActiveRecord::Base.establish_connection(config)
  #  ActiveRecord::Schema.verbose = false
  #
  #  if File.exists?(file)
  #    load(file)
  #  else
  #    abort %{#{file} doesn't exist yet. Run `rake db:migrate` to create it then try again. If you do not intend to use a database, you should instead alter #{Rails.root}/config/application.rb to limit the frameworks that will be loaded}
  #  end
  # end

  desc 'Create state and gs_schooldb dev and test dbs on dev workstations.'
  task :create, [:specific_dbs] => [:load_config, :rails_env] do |task, args|

    # logic taken from railties databases.rake
    config = (ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['database'].blank? }).first.clone

    $specific_dbs = String(args[:specific_dbs]).split ','

    environments.each do |env|
      $databases_receiving_mysql_dump.keys.each do |db|
        if $specific_dbs.empty? || $specific_dbs.include?(db)
          puts "Creating database #{db}"

          # not currently using the current environment within the db name. this may change
          # i.e. for test env we might create "_ca_test" for california
          config['database'] = db

          create_database config
        end
      end
    end
  end

  task :drop, [:specific_dbs] => [:load_config, :rails_env] do |task, args|
    # logic taken from railties databases.rake
    config = (ActiveRecord::Base.configurations.values_at(*environments).compact.reject { |config| config['database'].blank? }).first.clone

    $specific_dbs = String(args[:specific_dbs]).split ','

    # for each environment (development, test) create the dbs.
    environments.each do |env|
      $databases_receiving_mysql_dump.keys.each do |db|
        if $specific_dbs.empty? || $specific_dbs.include?(db)
          puts "Dropping database #{db} on #{config['host']}"

          config['database'] = db

          drop_database_and_rescue config
        end
      end
    end
  end

  task :reset, [:specific_dbs] => [:drop, :create, :migrate, :setup]

  namespace :schema do
    task :load_if_ruby, [:specific_dbs] => [:environment, :load_config] do |task, args|
      $specific_dbs = String(args[:specific_dbs]).split ','

      $databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
        if $specific_dbs.empty? || $specific_dbs.include?(db)
          $tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|
            load_schema db, db, table
          end
        end
      end
    end

    # desc 'Dump additional database schema'
=begin
    task :dump => [:load_config, :rails_env] do

      dbs = {
          _ca: 'state_schema',
          gs_schooldb: 'gs_schooldb_schema',
      }

      dbs.each_pair do |db, filename|
        dump_schema_from_dev db.to_s, filename
      end
    end
=end
  end
end


task :use_standard_connection do
  ActiveRecord::Base.custom_octopus_connection = true
  ActiveRecord::Base.establish_connection
end

task :use_octopus_connection do
  ActiveRecord::Base.custom_octopus_connection = false
  ActiveRecord::Base.establish_connection
end

task :'db:setup' => :use_standard_connection
task :'db:create' => :use_standard_connection
task :'db:schema:load_if_ruby' => :use_standard_connection
task :'db:schema:load' => :use_octopus_connection
task :'db:migrate' => :use_octopus_connection
task :'db:drop' => :use_standard_connection
task :'db:test:purge' => :use_standard_connection

