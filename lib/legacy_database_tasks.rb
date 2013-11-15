class LegacyDatabaseTasks
  require 'states'

  #Rails by default assumes that all the tables exist in one database.We are a using db_charmer to manage the legacy sharded
  #databases. The usual norm is to maintain the legacy schema in schema.rb file which is obtained by running 'rake db:schema:dump'
  #against the legacy databases. However we decided not to go this route for
  #a)Every time there is a change in schema in one of the legacy tables we have to keep it in sync.
  #b)The legacy tables were not being created correctly due to mysql version differences and MYISAM differences.
  #Hence the following workaround of dumping the schema and seeds from dev.


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
      TestDataSetFile
      TestDataBreakdown
      TestDataSubject
      TestDataType
      census_data_type
      school_media
    ),
      surveys_tables: %w(
      school_rating
    )
  }.stringify_keys!

  @@databases_receiving_mysql_dump = {
      _ca: :state_tables,
      _dc: :state_tables,
      gs_schooldb: :gs_schooldb_tables,
      surveys: :surveys_tables
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