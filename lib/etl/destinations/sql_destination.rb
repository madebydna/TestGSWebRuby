# frozen_string_literal: true

require_relative '../step'
require_relative './output_lib/insert_statement'
require_relative './output_lib/test_score_queue_daemon_json_blob'

class SqlDestination < GS::ETL::Step

  def initialize(output_file, config_hash, fields, required_fields, load_type)
    @output_file = output_file
    @sql = File.open(output_file, 'w')
    @fields = fields.empty? ? nil : fields.map(&:to_sym)
    @required_fields = (required_fields || []).map(&:to_sym)
    @source = config_hash 
    @load_type = load_type
  end

  def write(row)
    validate_row_has_required_fields(row)
    unless has_error?(row)
      @sql << InsertStatement.build(row, @source, @load_type)
    end
    row
  end

  def validate_row_has_required_fields(row)
    missing_fields = []
    if row.row_num < 2
      # a combination of the fields that are on the row, and the global fields available in @source
      fields_available_to_write = row.merge(@source)
      @required_fields.each do |field|
        if !fields_available_to_write.keys.include?(field) || fields_available_to_write[field].to_s == ''
          missing_fields << field
        end
      end
      if missing_fields.any?
        raise "Fields #{missing_fields.join(',')} are empty or not found"
        exit 1
      end
    end
  end

  def has_error?(row)
    row.has_key? :error
  end

  alias_method :process, :write

  def close
    @sql.close
  end

  def event_key
    @output_file
  end
end

