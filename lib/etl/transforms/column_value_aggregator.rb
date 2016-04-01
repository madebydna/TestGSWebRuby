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

class ColumnValueAggregator < GS::ETL::Step
  include GS::ETL::Source

  def initialize
    @hashes ||= Hash.new(0)
  end

  def process(row)
    row.each_pair do |key, value|
      @hashes[{column: key, value: value}] += 1
    end
    nil
  end

  def each
    sorted_hashes = Hash[ @hashes.sort_by { |k, v| k[:column] } ]
    sorted_hashes.each do |hash, occurences|
      yield(hash.merge(count: occurences).to_hash)
    end
  end
end
