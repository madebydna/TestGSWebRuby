require 'states'
require 'mysql2'

class DatabaseTasksHelper 

  # Rails by default assumes that all the tables exist in one database.We are a using db_charmer to manage the legacy sharded
  # databases. The usual norm is to maintain the legacy schema in schema.rb file which is obtained by running 'rake db:schema:dump'
  # against the legacy databases. However we decided not to go this route for
  # a)Every time there is a change in schema in one of the legacy tables we have to keep it in sync.
  # b)The legacy tables were not being created correctly due to mysql version differences and MYISAM differences.
  # Hence the following workaround of dumping the schema and seeds from dev.

  @@tables_receiving_mysql_dump = {
    state_tables: %w(
      school
      school_metadata
      esp_response
      census_data_set
      census_data_school_value
      census_data_district_value
      census_data_state_value
      TestDataSet
      TestDataStateValue
      TestDataDistrictValue
      TestDataSchoolValue
      district
    ),
    gs_schooldb_tables: %w(
      list_member
      list_active
      list_msl
      TestDataSetFile
      TestDataBreakdown
      TestDataSubject
      TestDataType
      census_data_breakdown
      census_data_type
      school_media
      ethnicity
      language
    ),
    surveys_tables: %w(
      school_rating
    ),
    community_tables: %w(
      reported_content
      alert_words
    )
  }.stringify_keys!

  @@databases_receiving_mysql_dump = {
      _ca: :state_tables,
      _dc: :state_tables,
      gs_schooldb: :gs_schooldb_tables,
      surveys: :surveys_tables,
      community: :community_tables
  }.stringify_keys!

  @@all_state_dbs = States.state_hash.values.map { |state| "_#{state.downcase}" }

  @@state_dbs_receiving_mysql_dump = %w(_ca _dc)

  @@state_dbs_receiving_mysql_dump.each { |state| @@databases_receiving_mysql_dump[state] = :state_tables }


  #Creates table schema and the seed data by doing a mysql dump.
  def self.copy_table_schema_and_data_from_server(source_server_config,
      source_database,
      source_table,
      destination_database = source_database)

    copy_table_schema_from_server source_server_config,source_database,source_table
    copy_data_from_server source_server_config,source_database,source_table

  end

  #Creates table schema by doing a mysql dump.
  def self.copy_table_schema_from_server(source_server_config,
      source_database,
      source_table,
      destination_database = source_database)

    puts "Creating table #{source_database}.#{source_table} from #{source_server_config['host']}"
    sql_command = "mysqldump -u#{source_server_config['username']} -p#{source_server_config['password']} -h#{source_server_config['host']} --compact -d #{source_database} #{source_table} | mysql -uroot #{destination_database}"
    system(sql_command)
    puts $?.success? ? "Creating #{source_table} completed." : "Creating #{source_table} failed."

  end

  # 
  # Dumps the database schema from source server for all given DBs
  # @param  source_mysql_server[Symbol] The host configuration in database.yml
  #         to use, .e.g. :mysql_dev
  # @param  destination_mysql_server[Symbol] The host configuration in 
  #         database.yml to use, .e.g. :mysql_localhost
  # @param  *databases [Array] array of database names
  # @param  overwrite = false [Boolean] If true will drop database and recreate
  # @param  &transform_db_name_block [Proc] A block to convert source db names
  #         to destination db names if needed
  # 
  # @return [nil]
  def self.copy_database_schemas_from_server(
    source_mysql_server, 
    destination_mysql_server, 
    databases, 
    overwrite = false,
    &transform_db_name_block
    )
    
    if transform_db_name_block
      destination_databases = databases.map &transform_db_name_block
    else
      destination_databases = databases
    end

    databases.each_with_index do |source_database, index|
      self.copy_database_schema_from_server(
        source_mysql_server, 
        destination_mysql_server, 
        source_database, 
        destination_databases[index],
        overwrite
      )
    end
  end

  # 
  # Creates table schemas for entire DB by doing a mysql dump
  # @param  source_mysql_server[Symbol] The host configuration in database.yml
  #         to use, .e.g. :mysql_dev
  # @param  destination_mysql_server[Symbol] The host configuration in 
  #         database.yml to use, .e.g. :mysql_localhost
  # @param  source_database [String] Source DB name
  # @param  destination_database = source_database [String] DB to create
  # @param  overwrite = false [Boolean] If true will drop database and recreate
  # 
  # @return [nil]
  def self.copy_database_schema_from_server(
    source_mysql_server,
    destination_mysql_server,
    source_database,
    destination_database = source_database,
    overwrite = false
    )

    source_mysql_config = 
    DatabaseConfigurationHelper.hashie_of_mysql_connection_info(
      source_mysql_server,
      false
    )
    destination_mysql_config = 
    DatabaseConfigurationHelper.hashie_of_mysql_connection_info(
      destination_mysql_server,
      false
    )

    mysql_client = Mysql2::Client.new(
      host: destination_mysql_config.host, 
      username: destination_mysql_config.username, 
      password: destination_mysql_config.password
    )

    database_exists = 
    mysql_client.query("show databases like '#{destination_database}'").any?

    database_has_tables = 
    database_exists && 
    (
      mysql_client.query("show tables in #{destination_database}")
      .any? rescue false
    )

    if database_exists == false || database_has_tables == false || overwrite
      if database_has_tables && overwrite
        drop_database(destination_mysql_server, destination_database)
        self.create_database(destination_mysql_server, destination_database)
      elsif database_exists == false
        # Create the database first
        self.create_database(destination_mysql_server, destination_database)
      end

      mysql_destination_string =  "mysql"
      mysql_destination_string << " -h#{destination_mysql_config.host}"
      mysql_destination_string << " -u#{destination_mysql_config.username}"
      if destination_mysql_config.password.present?
        mysql_destination_string << " -p#{destination_mysql_config.password}"
      end

      dump_db_command = "mysqldump -d"
      dump_db_command << " -h#{source_mysql_config.host}"
      dump_db_command << " -u#{source_mysql_config.username}"
      dump_db_command << " -p#{source_mysql_config.password}"
      dump_db_command << " #{source_database}"
      dump_db_command << " | #{mysql_destination_string}"
      dump_db_command << " -D#{destination_database}"

      puts "Dumping schema only from #{source_database} to \
#{destination_database} with command: #{dump_db_command}"

      system dump_db_command
      if $?.success?
        puts "Creating schema for #{destination_database} completed."
      else
        puts "Creating schema for #{destination_database} failed."
      end
    end
  end

  # 
  # Creates an empty database. Fails gracefully if it already exists
  # @param  destination_mysql_server [Symbol] The host configuration in 
  #         database.yml to use, .e.g. :mysql_dev
  # @param  destination_database[String] The destination database name
  # @param  overwrite = false [Boolean] If true will drop database and recreate
  # @return [nil]
  def self.create_database(
    destination_mysql_server, 
    destination_database, 
    overwrite = false
    )
    destination_mysql_config = 
    DatabaseConfigurationHelper.hashie_of_mysql_connection_info(
      destination_mysql_server,
      false
    )

    mysql_client = Mysql2::Client.new(
      host: destination_mysql_config.host, 
      username: destination_mysql_config.username, 
      password: destination_mysql_config.password
    )

    database_exists = 
    mysql_client.query("show databases like '#{destination_database}'").any?

    if database_exists == false || overwrite
      if database_exists && overwrite
        drop_database(destination_mysql_server, destination_database)
      end

      mysql_destination_string =  "mysql"
      mysql_destination_string << " -h#{destination_mysql_config.host}"
      mysql_destination_string << " -u#{destination_mysql_config.username}"
      if destination_mysql_config.password.present?
        mysql_destination_string << " -p#{destination_mysql_config.password}"
      end

      create_db_command = "echo 'create database #{destination_database}' | " + 
      mysql_destination_string

      puts "Creating database: #{destination_database}"
      unless system(create_db_command)
        puts 'Couldn\'t create database. Continuing on.'
      end
    else
      puts "#{destination_database} already exists. Skipping."
    end
  end

  # 
  # Drops a database. Fails gracefully if database doesn't exist.
  # @param  destination_mysql_server [Symbol] The host configuration in 
  #         database.yml to use, .e.g. :mysql_dev
  # @param  destination_database[String] The destination database name
  # @return [nil]
  def self.drop_database(
    destination_mysql_server, 
    destination_database 
    )
    destination_mysql_config = 
    DatabaseConfigurationHelper.hashie_of_mysql_connection_info(
      destination_mysql_server,
      false
    )

    mysql_client = Mysql2::Client.new(
      host: destination_mysql_config.host, 
      username: destination_mysql_config.username, 
      password: destination_mysql_config.password
    )

    puts "Dropping database #{destination_database}"
    dropped = mysql_client.query("drop database #{destination_database}")
  end

  #Creates the seed data by doing a mysql dump.
  def self.copy_data_from_server(source_server_config,
      source_database,
      source_table,
      destination_database = source_database,
      limit = 10000000)

    puts "seeding #{source_database}.#{source_table} from #{source_server_config['host']}"
    sql_command = "mysqldump -u#{source_server_config['username']} -p#{source_server_config['password']} -h#{source_server_config['host']} --compact --databases \"#{source_database}\" --tables \"#{source_table}\" --no-create-info --where \"1 limit #{limit}\" | tr -d \"\\`\" | mysql -uroot #{destination_database}"
    system(sql_command)
    puts $?.success? ? "Seeding #{source_table} completed." : "Seeding #{source_table} failed."
  end



  def self.databases_receiving_mysql_dump
  @@databases_receiving_mysql_dump
  end

  def self.tables_receiving_mysql_dump
    @@tables_receiving_mysql_dump
  end

  def self.state_dbs_receiving_mysql_dump
    @@state_dbs_receiving_mysql_dump
  end

end