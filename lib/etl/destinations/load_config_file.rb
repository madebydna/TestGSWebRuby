require 'step'
class LoadConfigFile < GS::ETL::Step
  def initialize(file, options = {})
    @file = File.open(file, 'w')
    @file.puts
    @notes = options.delete(:notes)
    @source_id = options.delete(:source_id)
    @state = options.delete(:state)
    @buffered_group_by = BufferedGroupBy.new(
      [
        :entity_level,
        :year, 
        :grade, 
        :level_code, 
        :data_type_id, 
        :subject_id
      ], [:breakdown_id, :proficiency_band_id]
    )
    @options = options
    self.write_file_header
  end

  def process(row)
    @buffered_group_by.process(row)
    nil
  end

  def run
    rows = @buffered_group_by.output_data
    rows_per_entity_level = rows.group_by do |row|
      row[:entity_level]
    end

    rows_per_entity_level.each do |entity_level, r|
      options = @options.merge(
        level: entity_level,
        file: @options[:file].gsub('[level]', entity_level)
      )
      Section.new(@file, r, entity_level, options).run
      @file.puts
      @file.puts
    end

    @file.close
  end

  def write_file_header
    data_loaded = Time.now.strftime("%F %T")
    @file.puts("state\t#{@state}")
    @file.puts("\tsource_id\tdate_loaded\tnotes")
    @file.puts("dataload\t#{@source_id}\t#{data_loaded}\t#{@notes}")
    @file.puts
  end

  class Section
    def initialize(file, rows, level, options)
      @file = file
      @rows = rows
      @level = level
      @options = options
      @fields = [
        :year, 
        :grade, 
        :level_code, 
        :data_type_id, 
        :subject_id, 
        :breakdown_id, 
        :proficiency_band_id
      ]
    end

    def run
      write_options
      write_headers
      write_data
      @file.puts
      write_vars
    end

    def write_options
      @options.each_pair do |key, value|
        @file.puts("#{key}\t#{value}")
      end
    end

    def base_vars
      {
        year: 'var:year',
        grade: 'var:grade',
        level_code: 'var:level_code',
        data_type_id: 'var:test_data_type_id',
        subject_id: 'var:subject_id',
        breakdown_id: 'var:breakdown_id',
        proficiency_band_id: 'var:proficiency_band_id',
        value_float_varname: 'value_float',
        num_varname: 'number_tested',
      }
    end

    def school_vars
      {
        state_id_1: 'var:state_id',
        queue_school_district_state_id: 'var:district_id',
        queue_school_name: 'var:school_name'
      }
    end

    def district_vars
      {
        district_state_id_1: 'var:state_id',
        queue_string_name: 'var:district_name'
      }
    end

    def state_vars
      {}
    end

    def write_vars
      vars = base_vars.merge(send("#{@level}_vars"))
      vars.each_pair do |key,value|
        @file.puts("#{key}\t#{value}")
      end
    end

    def write_headers
      headers = ['dataset'] + (@fields & @rows.first.keys)
      @file.puts(headers.join("\t"))
    end

    def write_data
      @rows.each do |row|
        
        if !! row[:proficiency_band_id].match(/null/) && row[:proficiency_band_id] != 'null'
          row[:proficiency_band_id] = row[:proficiency_band_id].gsub(',null', '')
        end
        values = @fields.map do |f|
          v = row[f]
          if %[breakdown_id proficiency_band_id level_code].include?(f.to_s)
            v = "\"#{v}\""
          end
          v
        end
        @file.puts("\t" << values.join("\t"))
      end
      @file.puts('end dataset')
    end
  end

end
