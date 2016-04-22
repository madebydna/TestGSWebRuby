require_relative 'test_processor'
require_relative 'destinations/csv_destination'
require_relative 'transforms/column_selector'
require_relative 'transforms/column_value_aggregator'

class ColumnValueReport < GS::ETL::TestProcessor

  def initialize(output_file, *fields)
    self.output_file = output_file
    self.fields = [*fields]
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
