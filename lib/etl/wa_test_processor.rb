$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'event_log'
require 'sources/csv_source'
require 'transforms/row_exploder'
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
require 'transforms/value_concatonator'
require 'transforms/unique_values'


class WATestProcessor < GS::ETL::DataProcessor

  def initialize(source_file, output_files)
    @source_file = source_file
    @state_output_file = output_files.fetch(:state)
    @school_output_file = output_files.fetch(:school)
    @district_output_file = output_files.fetch(:district)
    @unique_values_output_file = output_files.fetch(:unique_values)
  end

  def run
    combined_sources_step.destination CsvDestination, '/tmp/test_wa.txt'

    source_steps.each do |step|
      step.run
    end
  end

  def source_steps
    @_source_steps ||= (
      source_file_1 = '/Users/samson/Development/data/wa/2_23_SBA Scores by School.txt'
      source_file_2 = '/Users/samson/Development/data/wa/School_SBA_Scores_by_Subgroup_1.txt'

      source1 = CsvSource.new(source_file_1)
      source1.event_log = self.event_log

      source2 = CsvSource.new(source_file_2)
      source2.event_log = self.event_log

      [source1, source2]
    )
  end

  def combined_sources_step
    @_combined_sources_step ||= (
      s1 = source_steps[0]
      s1.transform Fill, SubGroup: nil, :'District ID' => nil

      s2 = source_steps[1]
      s2.transform Fill, CountyDistrictNumber: nil, ESD: nil
      s2.transform Fill, ESD: nil

      combined_sources_step = s1.add_step(GS::ETL::Step)
      s2.add(combined_sources_step)

      combined_sources_step
    )
  end

end

# ca2015_all_csv_v1_sample.txt

# file = '/Users/jwrobel/dev/data/ca2015_all_csv_v1_100000.txt'

file = '/Users/samson/Development/data/ca2015_RM_csv_v1_all.txt'

output_files = {
    state: '/tmp/ca.2015.1.public.charter.state.txt',
    school: '/tmp/ca.2015.1.public.charter.school.txt',
    district: '/tmp/ca.2015.1.public.charter.district.txt',
    unique_values: '/tmp/ca.2015.unique_files.txt'
}

WATestProcessor.new(file, output_files).run



