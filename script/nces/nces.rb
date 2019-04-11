#! /usr/bin/env ruby

require 'net/http'
require 'json'
require 'cgi'

class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
end

class FixedWidthWriter
  require 'pathname'

  def initialize(file_path: nil, write_headers: true, **args)
    @write_headers = write_headers
    @io = Pathname.new(file_path).open('w') if file_path
    @io ||= STDOUT
    @field_widths = Hash.new { |h, k| h[k] = k.to_s.length }
    @first_row = true
    @buffer = []
  end

  def <<(hash)
    hash.each_key do |k|
      @field_widths[k] = [@field_widths[k], hash[k].to_s.length].max
    end
    buffer(hash)
  end

  def close
    write_buffer
    @io.close
  end

  private

  def buffer(hash)
    @buffer << hash
  end

  def write_buffer
    @buffer.each do |row|
      field_names = @field_widths.keys
      @io << (pattern % field_names) + "\n" if @first_row && @write_headers
      @first_row = false
      @io << (pattern % row.slice(*field_names).values(&:to_s))
      @io << "\n"
    end
  end

  # a string formatter pattern used to format each row
  def pattern
    @_pattern ||= @field_widths.values.reduce("") { |str,w| str << "%-#{w+3}s" }
  end
end


class SchoolQuery
  def initialize
    @fields = %w[
      NCESSCH
      SURVYEAR
      STABR
      ST_LEAID
      LEA_NAME
      SCH_NAME
      MSTREET1
      MSTREET2
      MSTREET3
      MCITY
      MSTATE
      MZIP
      MZIP4
      PHONE
      SCH_TYPE_TEXT
      GSLO
      GSHI
      SY_STATUS_TEXT
      LATCOD
      LONCOD
      GSLO_NUM
      GSHI_NUM
      NMCNTY
      SLEVEL_TEXT
      GEOSEARCH
      ST_SCHID
      STATUS
    ]
    @geometry = false
    @format = 'json'
    @criteria = nil
    @field_map = {
      state: 'STABR',
      school_name: 'SCH_NAME'
    }
  end

  def field_name(field)
    @field_map[field.to_sym] || field
  end

  def where(hash)
    hash.each_pair do |field, value|
      if @criteria
        @criteria << " AND "
      else
        @criteria = ''
      end

      if value[0] == '%' || value[-1] == '%'
        @criteria << "#{field_name(field)} LIKE '#{value}'"
      else
        @criteria << "#{field_name(field)} = '#{value}'"
      end
    end
    return self
  end

  def to_s
    raise "Empty query" unless @criteria && !@criteria.empty?
    "?f=#{@format}&where=#{::CGI.escape(@criteria)}&returnGeometry=#{@geometry}&outFields=#{@fields.join(',')}"
  end
end

class Response
  def initialize(hash)
    @data = hash
  end

  def raw_results
    @data.dig('features').map { |item| item['attributes'] }
  end

  def short_results
    @data.dig('features').map do |item|
      item = item['attributes']
      {
        'name' => item['SCH_NAME'],
        'nces_code' => item['NCESSCH'],
        'state_school_id' => item['ST_SCHID'],
        'state' => item['STABR'],
        'state_district_id' => item['ST_LEAID'],
        'district' => item['LEA_NAME'],
        'county' => item['NMCNTY'],
        'street' => item['MSTREET1'],
        'city' => item['MCITY'],
        'zip' => item['MZIP'],
        'grade_range' => [item['GSLO_NUM'], item['GSHI_NUM']].compact.join('-'),
        'status' => item['SY_STATUS_TEXT'],
      }
    end
  end

  def results
    @data.dig('features').map do |item|
      item = item['attributes']
      {
        'name' => item['SCH_NAME'],
        'nces_code' => item['NCESSCH'],
        'state_school_id' => item['ST_SCHID'],
        'state' => item['STABR'],
        'state_district_id' => item['ST_LEAID'],
        'district' => item['LEA_NAME'],
        'county' => item['NMCNTY'],
        'mail_street' => item['MSTREET1'],
        'street_line_2' => [item['MSTREET2'], item['MSTREET3']].compact.join(' '),
        'mail_city' => item['MCITY'],
        'mail_zipcode' => [item['MZIP'], item['MZIP4']].compact.join(''),
        'mail_state' => item['MSTATE'],
        'phone' => item['phone'],
        'type' => item['SCH_TYPE_TEXT'],
        'level' => item['SLEVEL_TEXT'],
        'year' => item['SURVYEAR'],
        'geosearch' => item['GEOSEARCH'],
        'status' => item['STATUS'],
        'grade_range' => [item['GSLO_NUM'], item['GSHI_NUM']].compact.join('-'),
        'lat' => item['LATCOD'],
        'lon' => item['LONCOD'],
        'status_text' => item['SY_STATUS_TEXT'],
      }
    end
  end
end

class SchoolSearcher
  def initialize
    @host = 'https://nces.ed.gov'
    @school_path = '/arcgis/rest/services/CCD/CCD_201516/MapServer/4/query'
    @district_path = '/arcgis/rest/services/CCD/CCD_201516/MapServer/1/query'
  end

  def url
    @host + @school_path
  end

  def search(query)
    response = Net::HTTP.get(URI(url + query.to_s))
    Response.new(JSON.parse(response))
  end
end

query = SchoolQuery.new
query.where(school_name: 'Alameda%', state: 'CA')
response = SchoolSearcher.new.search(query)
writer = FixedWidthWriter.new
response.short_results.each { |h| writer << h }
writer.close
