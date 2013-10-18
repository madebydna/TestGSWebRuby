class LegacyDatabaseTasks
  require 'states'

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

  @@all_legacy_dbs = (@@databases_receiving_mysql_dump.keys + @@all_state_dbs).uniq!

  @@state_dbs_receiving_mysql_dump = %w(_ca _dc)

  @@state_dbs_receiving_mysql_dump.each { |state| @@databases_receiving_mysql_dump[state] = :state_tables }


  def self.create_tables_and_seeds
    $specific_dbs ||= []
    mysql_dev = Rails.application.config.database_configuration['mysql_dev']

    $databases_receiving_mysql_dump.each_pair do |db, tables_hash_key|
      if $specific_dbs.empty? || $specific_dbs.include?(db)
        $tables_receiving_mysql_dump[tables_hash_key.to_s].each do |table|

          copy_table_schema_from_server mysql_dev, db, table
          copy_data_from_server mysql_dev, db, table
        end
      end
    end
  end

  def self.copy_table_schema_from_server(source_server_config,
      source_database,
      source_table,
      destination_database = source_database)

    puts "Creating table #{source_database}.#{source_table} from #{source_server_config['host']}"
    sql_command = "mysqldump -u#{source_server_config['username']} -p#{source_server_config['password']} -h#{source_server_config['host']} --compact -d #{source_database} #{source_table} | mysql -uroot #{destination_database}"
    system(sql_command)
    puts $?.success? ? "Creating #{source_table} completed." : "Creating #{source_table} failed."

  end

  def self.copy_data_from_server(source_server_config,
      source_database,
      source_table,
      destination_database = source_database,
      limit = 10000000)

    puts "seeding #{source_database}.#{source_table} from #{source_server_config['host']}"
    sql_command = "mysqldump -u#{source_server_config['username']} -p#{source_server_config['password']} -h#{source_server_config['host']} --compact --databases \"#{source_database}\" --tables \"#{source_table}\" --skip-set-charset --no-create-info --skip-comments --where \"1 limit #{limit}\" | tr -d \"\\`\" | mysql -uroot #{destination_database}"
    system(sql_command)
    puts $?.success? ? "Seeding #{source_table} completed." : "Seeding #{source_table} failed."
  end

  def self.all_legacy_dbs
  @@all_legacy_dbs
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