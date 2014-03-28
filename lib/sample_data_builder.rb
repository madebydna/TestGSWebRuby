require 'mysql2'
require 'json'

class SampleDataBuilder
  attr_accessor :name, :db, :table
  attr_reader :mysql_client, :array_to_write

  def initialize(name, options = {})
    @name = name
    @db = options[:db]
    @table = options[:table]
    @array_to_write = []

    host = options[:host]
    username = options[:username]
    password = options[:password]
    @mysql_client = Mysql2::Client.new(:host => host, :username => username, :password => password)
  end

  def query(q, options = {})
    db = options[:db] || self.db
    table = options[:table] || self.table

    mysql_client.select_db db

    results = mysql_client.query q

    @array_to_write << {
        name: name,
        db: db,
        table: table,
        data: results.to_a
    }
  end

  def data_directory
    File.join(File.dirname(__FILE__), '..', 'db', 'sample_data', 'data')
  end

  def write_file
    File.open(file, 'a') do |f|
      f.write JSON.pretty_unparse array_to_write
    end
  end

  def file
    File.join(data_directory, "#{name}.json")
  end

  # def sample_data_files
  #   Dir[ File.join(data_directory, "#{name}*.json") ]
  # end

  def delete_sample_data
    File.delete file if File.exist?(file)
  end
end