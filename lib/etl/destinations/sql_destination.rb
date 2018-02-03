# frozen_string_literal: true

require_relative '../step'

class SqlDestination < GS::ETL::Step

  def initialize(output_file, config_hash, *fields)
    @output_file = output_file
    @sql = File.open(output_file, 'w')
    @fields = fields.empty? ? nil : fields
    @source = config_hash
  end

  def write(row)
    unless has_error?(row)
      json_str = TestScoreQueueDaemonJsonBlob.new(row, @source).build
      @sql << QueueDaemonInsertStatement.build(@source[:source_name], json_str)
    end
    row
  end

  alias_method :process, :write

  def close
    @sql.close
  end

  def event_key
    @output_file
  end
end

