$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
require 'event_log'
require 'sources/gs_sharded_database_source'
require 'transforms/filter_out_matching_values'
require 'destinations/csv_destination'
require 'destinations/event_report_stdout'


class  MisMatchFinder < GS::ETL::TestProcessor

  def initialize(source_args, values_to_match, output_file)
    @source_args = source_args
    @output_file = output_file
    @values_to_match = values_to_match
  end

  def run
    schools_in_gs_ca_db = source GsShardedDatabaseSource, @source_args
    schools_in_gs_ca_db.transform FilterOutMatchingValues,
      @values_to_match,
      'state_id'

    schools_in_gs_ca_db.destination CsvDestination, @output_file
    event_log.destination EventReportStdout

    system('clear')
    schools_in_gs_ca_db.transform RunOtherStep, event_log

    schools_in_gs_ca_db.root.run
  end

end

class GetValuesFromTextFile
  def initialize(file, regex, &post_regex_block)
    @text = File.open(file).read
    @regex = regex
    @post_regex_map_block = Proc.new(&post_regex_block) || proc { |v| v }
  end

  def unique_regex_matches
    @text.scan(@regex).uniq
  end

  def values
    unique_regex_matches.map(&@post_regex_map_block)
  end
end

ca_test_load_file = '/Users/jwrobel/dev/ca2015_all_csv_v1.txt'
school_ids_regex_for_ca_test_load = /"\d*","\d*","\d{7}"(?=,)/
state_ids_in_file_extractor = GetValuesFromTextFile.new(ca_test_load_file,
                                                        school_ids_regex_for_ca_test_load
                                                       ) { |id| id.gsub('"','').gsub(',','') }
state_ids_in_file = state_ids_in_file_extractor.values

source_args = {
  host: 'ditto',
  state: 'ca',
  table: 'school',
  where: "where state_id != '' AND type in('public', 'charter') AND level_code !='p' and active = 1"
}

output_file = '/tmp/state_ids_in_database_not_in_load_test_3.csv'
MisMatchFinder.new(source_args, state_ids_in_file, output_file).run
