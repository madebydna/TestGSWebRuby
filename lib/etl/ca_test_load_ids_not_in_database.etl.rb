$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
require 'sources/gs_sharded_database_source'
require 'transforms/filter_out_matching_values'
require 'transforms/value_concatenator'
require 'destinations/csv_destination'
require 'sources/csv_source'
require 'gs_school_ids_fetcher'
require 'destinations/event_report_stdout'

class  MisMatchFinder < GS::ETL::TestProcessor

  def initialize(source_file, values_to_match, output_file)
    @source_file = source_file
    @output_file = output_file
    @values_to_match = values_to_match
  end

  def run
    ca_test_load = source CsvSource, @source_file

    ca_test_load.transform ValueConcatenator, :state_id,
                                              :county_code,
                                              :district_code,
                                              :school_code


#   Need to add filter out duplicate values transform
    ca_test_load.transform FilterOutMatchingValues,
      @values_to_match,
      :state_id
      
    #
    # ca_test_load.transform FilterOutMatchingValues, 
    #   ['0000000'],
    #   :school_code


    ca_test_load.destination CsvDestination, @output_file
    # event_log.destination EventReportStdout
#
    # system('clear')
    # ca_test_load.transform RunOtherStep, event_log
    #
    ca_test_load.root.run
  end

end

ca_test_load_file = '/Users/jwrobel/dev/data/ca2015_all_csv_v1.txt'
destination_file =  '/tmp/all_ids_in_test_load_and_not_in_gs_ca_db.csv'
state_ids_in_database = GsSchoolIdsFetcher.new('ditto', 'ca').values_array

MisMatchFinder.new(ca_test_load_file, state_ids_in_database, destination_file).run
