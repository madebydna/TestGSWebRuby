$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
require 'event_log'
require 'sources/csv_source'
require 'transforms/transposer'
require 'transforms/joiner'
require 'transforms/hash_lookup'
require 'transforms/field_renamer'
require 'transforms/multi_field_renamer'
require 'destinations/csv_destination'
require 'transforms/trim_leading_zeros'
require 'destinations/event_report_stdout'
require 'destinations/load_config_file'
require 'sources/buffered_group_by'
require 'transforms/fill'
require 'ca_entity_level_parser'
require 'transforms/with_block'
require 'gs_breakdown_definitions'
require 'gs_breakdowns_from_db'
require 'transforms/column_selector'
require 'transforms/keep_rows'
require 'transforms/value_concatenator'
require 'transforms/unique_values'
require 'transforms/column_value_aggregator'

class ColumnValueReport < GS::ETL::TestProcessor

  def initialize(output_file, *fields)
    self.output_file = output_file
    self.fields = [*fields]
    build_graph
  end

  def build_graph
    @attachable_input_step = ColumnSelector.new(*@fields)
    aggregator = @attachable_input_step.transform(
      "Aggregate distinct values per column",
      ColumnValueAggregator
    )
    @attachable_output_step = aggregator.destination(
      "Output distinct values per column to CSV",
      CsvDestination,
      @output_file
    )
    @runnable_steps = [aggregator]
    @attachable_input_step
  end

  def fields=(fields)
    @fields = fields
  end

  def output_file=(output_file)
    @output_file = output_file
  end

end
