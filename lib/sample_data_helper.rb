require_relative 'sample_data_builder.rb'


def write_sample_data(name, db, table = nil, &blk)
  # If this is being executed from the context of a query script, create output
  # json in a parallel directory structure
  # Otherwise, just place the file in sample_data/data (not in any subfolder)
  if caller[0].match('.rb:') && caller[0].match('/db/sample_data/queries/')
    subdirectory = caller[0].split('/queries/').last.split('/').first
    name = File.join(subdirectory, name) unless subdirectory.match '.rb'
  end

  host = ENV['mysql_host']
  username = ENV['mysql_username']
  password = ENV['mysql_password']

  if (host.nil? || username.nil?)
    raise 'You must specify ENV["mysql_host"], ENV["mysql_username"], and ENV["mysql_password]'
  end

  builder = SampleDataBuilder.new name,
                                  host: host,
                                  username: username,
                                  password: password,
                                  db: db,
                                  table: table

  builder.delete_sample_data
  blk.call(builder)
  builder.write_file
end

# This function expects to be ran in the context of a rails environment
def load_sample_data(name, env = 'test')
  files = Dir.glob(Rails.root.join('db', 'sample_data', 'data', '**/', "#{name}.json"))

  db_suffix = (env == 'test')? "_#{env}" : ''

  database_connection_config =
    DatabaseConfigurationHelper.database_config_for "_ca#{db_suffix}", env

  host = database_connection_config['host']
  username = database_connection_config['username']
  password = database_connection_config['password']

  mysql_client = Mysql2::Client.new(:host => host, :username => username, password: password)

  files.each do |file|
    array = JSON.parse(File.read file)
    array.each do |hash|
      db = hash['db']
      table = hash['table']
      data = hash['data']

      db = db + '_test' if env == 'test'

      column_names = hash['data'][0].keys
      column_names_string = column_names.join ','

      data.each do |row|
        values = row.values
        values = values.map do |value|
          v = if value.is_a?(String)
                if value.include? '"'
                  value.to_json
                else
                  '"' + value + '"'
                end
              elsif value.is_a?(Hash)
                JSON.pretty_unparse(value)
              elsif value.nil?
                'NULL'
              else
                value
              end
        end
        values_string = values.join(",")
        values_string.gsub! "'NULL'", 'NULL'

        sql = "insert into #{table}(#{column_names_string}) values(#{values_string})"
        begin
          # puts 'using sql: ' + sql
          mysql_client.select_db db
          mysql_client.query sql
        rescue => e
          puts "Statement: #{sql} \ngenerated error: #{e.message}. Skipping."
        end
      end
    end
  end
end
