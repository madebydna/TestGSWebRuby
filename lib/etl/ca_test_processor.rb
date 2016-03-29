$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'test_processor'
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
require 'transforms/value_concatenator'
require 'transforms/unique_values'


class CATestProcessor < GS::ETL::TestProcessor

  def initialize(source_file, output_files)
    @source_file = source_file
    @state_output_file = output_files.fetch(:state)
    @school_output_file = output_files.fetch(:school)
    @district_output_file = output_files.fetch(:district)
    @unique_values_output_file = output_files.fetch(:unique_values)
  end

  def run
    ca_test_data_load_lookup_table = {
        '1' => "All Students: All Students",
        '3' => "Males: Gender",
        '4' => "Females: Gender",
        '6' => "Fluent-English Proficient and English Only: English-Language Fluency",
        '7' => "Initially-Fluent English Proficient (I-FEP): English-Language Fluency",
        '8' => "Reclassified-Fluent English Proficient (R-FEP): English-Language Fluency",
        '28' => "Migrant Education: Migrant",
        '31' => "Economically Disadvantaged: Economic Status",
        '74' => "Black or African American: Ethnicity",
        '75' => "American Indian or Alaska Native: Ethnicity",
        '76' => "Asian: Ethnicity",
        '77' => "Filipino: Ethnicity",
        '78' => "Hispanic or Latino: Ethnicity",
        '79' => "Native Hawaiian or Pacific Islander: Ethnicity",
        '80' => "White: Ethnicity",
        '90' => "Not a High School Graduate: Parent Education",
        '91' => "High School Graduate: Parent Education",
        '92' => "Some College (Includes AA Degree): Parent Education",
        '93' => "College Graduate: Parent Education",
        '94' => "Graduate School/Post Graduate: Parent Education",
        '99' => "Students with No Reported Disability: Disability Status",
        '111' => "Not Economically Disadvantaged: Economic Status",
        '120' => "English Learners Enrolled in School in the U.S. Less Than 12 Months: English-Language Fluency",
        '121' => "Parent Education -- Declined to State: Parent Education",
        '128' => "Students with Disability: Disability Status",
        '142' => "English Learners Enrolled in School in the U.S. 12 Months or More: English-Language Fluency",
        '144' => "Ethnicity -- Two or More Races: Ethnicity",
        '160' => "English Learner: English-Language Fluency",
        '180' => "English Only: English-Language Fluency",
        '200' => "Black or African American: Ethnicity for Economically Disadvantaged",
        '201' => "American Indian or Alaska Native: Ethnicity for Economically Disadvantaged",
        '202' => "Asian: Ethnicity for Economically Disadvantaged",
        '203' => "Filipino: Ethnicity for Economically Disadvantaged",
        '204' => "Hispanic or Latino: Ethnicity for Economically Disadvantaged",
        '205' => "Native Hawaiian or Pacific Islander: Ethnicity for Economically Disadvantaged",
        '206' => "White: Ethnicity for Economically Disadvantaged",
        '207' => "Ethnicity -- Two or More Races: Ethnicity for Economically Disadvantaged",
        '220' => "Black or African American: Ethnicity for Not Economically Disadvantaged",
        '221' => "American Indian or Alaska Native: Ethnicity for Not Economically Disadvantaged",
        '222' => "Asian: Ethnicity for Not Economically Disadvantaged",
        '223' => "Filipino: Ethnicity for Not Economically Disadvantaged",
        '224' => "Hispanic or Latino: Ethnicity for Not Economically Disadvantaged",
        '225' => "Native Hawaiian or Pacific Islander: Ethnicity for Not Economically Disadvantaged",
        '226' => "White: Ethnicity for Not Economically Disadvantaged",
        '227' => "Ethnicity -- Two or More Races: Ethnicity for Not Economically Disadvantaged"
    }

    s1 = GS::ETL::StepsBuilder.new(self.source_step)

    s1.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
      :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested,
      :percentage_standard_exceeded, :percentage_standard_met, :percentage_standard_nearly_met, 
      :percentage_standard_not_met

    s1.transform Fill,
      test_data_type: 'caasp',
      entity_type: 'public_charter',
      school_name: 'school_name',
      district_name: 'district_name',
      level_code: 'e,m,h'

    s1.transform ValueConcatonator, :state_id, :county_code,
      :district_code, :school_code

    s1.transform RowExploder,
      :proficiency_band,
      :proficiency_band_value,
      :percentage_standard_exceeded,
      :percentage_standard_met,
      :percentage_standard_nearly_met,
      :percentage_standard_not_met

    # Map proficiency band IDs
    s1.transform(
      HashLookup,
      :proficiency_band,
      {
        percentage_standard_exceeded: 25,
        percentage_standard_met: 24,
        percentage_standard_nearly_met: 23,
        percentage_standard_not_met: 22,
        '' => 'null'
      },
      to: :proficiency_band_id
    )

    s1.transform(
      HashLookup,
      :test_data_type,
      {
        'caasp' => 236
      },
      to: :test_data_type_id
    )

    s1.transform(
      HashLookup,
      :test_data_type,
      {
        'caasp' => 236
      },
      to: :data_type_id
    )

    s1.transform MultiFieldRenamer, {
      district_code: :district_id,
      school_code: :school_id,
      test_year: :year,
      test_id: :subject,
      subgroup_id: :ca_breakdown_id,
      students_tested: :number_tested
    }

    s1.transform TrimLeadingZeros, :grade

    s1.transform(
      HashLookup,
      :subject,
      {
        '2' => 5,
        '1' => 4,
        'science' => 25,
      },
      to: :subject_id
    )

    s1.transform(
      HashLookup,
      :ca_breakdown_id,
       GsBreakdownDefinitions.breakdown_lookup,
      to: :gs_breakdown_id,
      ignore: ['6','7','8','90','91','92','93','94','121''202','200','203',
               '205','206', '207','220','221','222','223','204','201','224',
               '225','226','227','180', '120','142']
    )

    s1.transform FieldRenamer, :proficiency_band_value, :value_float

    s1.transform WithBlock do |row|
      CaEntityLevelParser.new(row).parse
    end

    s1.transform(HashLookup, :gs_breakdown_id, GsBreakdownsFromDb.fetch, to: :gs_breakdown_label)

    s1.transform(HashLookup, :ca_breakdown_id, ca_test_data_load_lookup_table, to: :ca_breakdown_label)
    # s1.destination CsvDestination, @output_file

    last_node_before_split = s1.transform KeepRows, ['district','school','state'], :entity_level

    node_for_state_only_data = last_node_before_split.transform KeepRows, ['state'], :entity_level

    node_for_school_only_data = last_node_before_split.transform KeepRows, ['school'], :entity_level

    node_for_district_only_data = last_node_before_split.transform KeepRows, ['district'], :entity_level

    node_for_config_file = last_node_before_split.destination LoadConfigFile, '/tmp/config.ca.2015.test.1.txt', {
      source_id: 7,
      state: 'ca',
      notes: 'Year 2015 CA TEST',
      url: 'http://caaspp.cde.ca.gov/sb2015/ResearchFileList',
      file: 'ca/2015/output/ca.2015.1.public.charter.[level].txt',
      level: nil,
      school_type: 'public,charter'
    }

    column_order = [ :year, :entity_type, :entity_level, :state_id, :school_id, :school_name,
      :district_id, :district_name, :test_data_type, :test_data_type_id, :grade,
      :subject, :subject_id, :breakdown, :breakdown_id, :proficiency_band,
      :proficiency_band_id, :level_code, :number_tested, :value_float]

    node_for_state_only_data.destination CsvDestination, @state_output_file, *column_order
    node_for_school_only_data.destination CsvDestination, @school_output_file, *column_order
    node_for_district_only_data.destination CsvDestination, @district_output_file, *column_order

    unique_values = s1.transform(UniqueValues, :ca_breakdown_label, :ca_breakdown_id, :gs_breakdown_label, :gs_breakdown_id)

    s1.destination CsvDestination, @unique_values_output_file, :ca_breakdown_label, :ca_breakdown_id, :gs_breakdown_label, :gs_breakdown_id
    # event_log.destination EventReportStdout

    # system('clear')
    # s1.transform RunOtherStep, event_log
    #
    source_step.run
    node_for_config_file.run
    unique_values.run

  end

  def source_step
    @_source_step ||= (
      step = CsvSource.new(@source_file)
      step.event_log = self.event_log
      step
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

CATestProcessor.new(file, output_files).run



