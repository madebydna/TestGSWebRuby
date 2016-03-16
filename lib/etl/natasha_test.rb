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
require 'transforms/unique_values'

class CATestProcessor < GS::ETL::DataProcessor

  def initialize(source_file, output_file)
    @source_file = source_file
    @output_file = output_file
  end

  def run
    s1 = source CsvSource, @source_file

    s1.transform Fill,
                 test_data_type: 'caasp',
                 entity_type: 'public_charter',
                 school_name: 'school_name',
                 district_name: 'district_name',
                 level_code: 'e,m,h'

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

    s1.transform MultiFieldRenamer, {
        district_code: :district_id,
        school_code: :school_id,
        test_year: :year,
        test_id: :subject,
        subgroup_id: :ca_breakdown_id,
        students_tested: :number_tested,
        test_year: :year
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
    s1.transform FieldRenamer, :proficiency_band_value, :school_value_float
    s1.transform FieldRenamer, :students_tested, :number_tested
    s1.transform FieldRenamer, :test_year, :year

    s1.transform WithBlock do |row|
      CaEntityLevelParser.new(row).parse
    end

    # hash_of_ca_test_breakdown_keys_and_gs_values = {
    #     every_student: '1',
    #     asian: '5',
    #     latino: '23',
    #     free_lunch: '68',
    #     non_gs_label: 'null'
    # }

    # hash_of_gs_breakdown_mapping = {
    #     1 => 'all',
    #     5 => 'asian',
    #     23 => 'latino',
    #     68 => 'frl'
    # }

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

    # p GsBreakdownsFromDb.new
    # p GsBreakdownDefinitions.new

    s1.transform(HashLookup, :gs_breakdown_id, GsBreakdownsFromDb.fetch, to: :gs_breakdown_label)
    # require 'pry'; binding.pry
    s1.transform(HashLookup, :ca_breakdown_id, ca_test_data_load_lookup_table, to: :ca_breakdown_label)

    s1.destination CsvDestination, @output_file, :year, :entity_type,
                   :entity_level, :state_id, :school_id, :school_name, :district_id,
                   :district_name, :test_data_type, :test_data_type_id, :grade,
                   :subject, :subject_id, :ca_breakdown_id, :ca_breakdown_label, :gs_breakdown_label, :gs_breakdown_id, :proficiency_band,
                   :proficiency_band_id, :level_code, :number_tested, :value_float

    s1.transform(UniqueValues, :ca_breakdown_label, :ca_breakdown_id, :gs_breakdown_label, :gs_breakdown_id)

    s1.destination CsvDestination, @output_file, :ca_breakdown_label, :ca_breakdown_id, :gs_breakdown_label, :gs_breakdown_id

    s1.root.run
    #s2.run
  end
end

file = '/vagrant/GSWebRuby/tmp/ca2015_RM_csv_v1_sample.txt'
# file = '/Users/samson/Development/data/ca2015_RM_csv_v1_all.txt'
output_file = '/vagrant/GSWebRuby/tmp/new_test_file_.tsv'
CATestProcessor.new(file, output_file).run

