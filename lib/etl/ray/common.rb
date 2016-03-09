require 'csv'

class CsvSource
  def initialize(file, options)
    @file = file
    @options = options
  end

  def each
    CSV.foreach(@file,@options) do |row|
      yield row.to_hash
    end
  end
end

class CsvDestination
  def initialize(output_file)
    @csv = CSV.open(output_file, 'w')
  end

  def write(row)
    unless @headers_written
      @headers_written = true
      @csv << row.keys
    end
    @csv << row.values
  end

  def close
    @csv.close
  end
end

# require 'mysql2'
# require 'uri'

# class MySqlDestination
#   # connect_url should look like;  
#   # mysql://user:pass@localhost/dbname
#   connect_url = "mysql://root:password@localhost/rays_kiba_test"
  
#   def initialize(connect_url)
#     @mysql = Mysql2::Client.new(connect_hash(connect_url))  
#     # @mysql = Mysql2::Client.new(connect_url)
#     @mysql.prepare('kiba_example', 'insert into example (email, password_digest, created_at, updated_at) values ($1, $2, $3, $4)')
#   end

#   def write(row)
#     time = Time.now 
#     @mysql.exec_prepared('kiba_example', [ row[:email], row[:password], row[:date_created], time ])
  
#     rescue Mysql2::Error => ex
#     puts "ERROR for #{row[:email]}"
#     puts ex.message
#     # Maybe, write to db table or file
#   end

#   def close
#     @mysql.close 
#     @mysql = nil
#   end
# end 

class ShaveZeros
  def initialize(field_name)
    @field_name = field_name
  end

  def process(row)
    field_value = row[@field_name]
    field_value.sub!(/^0+/, "")
    row[@field_name] = field_value
    row
  end
end

class ConcatFieldValues
  def initialize(arr_field_names,dest_name)
    @field_names = arr_field_names
    @dest_name = dest_name
  end

  def process(row)
    field_value = ""
    @field_names.each do |item| 
      field_value << row[item].to_s
      #@result.to_s << field_value.to_s
      puts item , field_value
    end
    row[@dest_name] = field_value
    row
  end
end

# class RenameField
#   def initialize(from:, to:)
#     @from = from
#     @to = to
#   end
  
#   def process(row)
#     row[@to] = row.delete(@from)
#     row
#   end
# end

require 'awesome_print'

def show_me!
  transform do |row|
    ap row
    row
  end
end

# def concat_state_id!
#   transform do |row|
#     # set value var 
#     state_id = row[:county_code] + row[:district_code] + row[:school_code]
#     # return value
#     row[:state_id] = state_id
#     # return the valid row to keep it
#     row
#   end
# end

# def shave_zeros!
#   transform do |row|
#     # set value vars 
#     county_code = row[:county_code]
#     district_code = row[:district_code]
#     school_code = row[:school_code]
    
#     # remove leading zeros
#     county_code.sub!(/^0+/, "")
#     district_code.sub!(/^0+/, "")
#     school_code.sub!(/^0+/, "")

#     # return value
#     row[:county_code] = county_code
#     row[:district_code] = district_code
#     row[:school_code] = school_code


#     # return the valid row to keep it
#     #row_invalid = county_code.empty? && district_code.empty?
#     #row_invalid ? nil : row
#   end
# end

# before declaring a definition, maybe you'll want to retrieve credentials
# config = YAML.load(IO.read('config.yml'))





