# simple destination assuming all rows have the same fields
class QueueFile

  def initialize(output_file)
    @output_file = output_file
    @output = File.open(output_file, 'w')
  end
  
  def write_queue(row)
    if has_error?(row)
      write_error(row)
    else
      write_file(row)
    end 
  end

  def has_error?(row)
    row.has_key? :error
  end

  def write_error(row)
    fields = row.keys
    if fields
      row = row.select { |k| fields.include?(k) }
    end
    unless @headers_written_error
      @headers_written_error = true
      @error_log << fields
    end
    record(row, 'Wrote row')
    @error_log << fields.map { |f| row[f] }
    row
  end

  def write_file(row)
    school_or_district = row[:entity_type]
    original_id = 0
    district_id = 0
    name = write_name(row)
    state_id = row[:state_id]
    result = ['school_or_district',school_or_district,'original_id',original_id,'district_id',district_id,'name',name,'state_id',state_id]
    @output << result.join(':queue_modifier:')
    @output << "\n"
    row
  end

  def write_name(row)
    key = :"#{row[:entity_type]}_name"
    if row[key].nil?
      name = "TEST LOAD #{row[:entity_level]} #{row[:state_id]}"
    else
      name = row[key]
    end
    name
  end

  def close
    @output.close
  end

  def event_key
    @output_file
  end
end

