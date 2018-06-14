# frozen_string_literal: true

require_relative '../step'
require_relative './output_lib/gsdata_insert_statement'
require_relative './output_lib/test_score_queue_daemon_json_blob'

class SqlDestination < GS::ETL::Step

  def initialize(output_file, config_hash, *fields)
    @output_file = output_file
    @sql = File.open(output_file, 'w')
    @fields = fields.empty? ? nil : fields
    @source = config_hash 
  end

  def write(row)
    unless has_error?(row)
      #json_str = TestScoreQueueDaemonJsonBlob.new(row, @source).build
      @sql << GSdataInsertStatement.build(row, @source)
    end
    row
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

