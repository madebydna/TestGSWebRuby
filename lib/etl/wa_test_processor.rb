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
    # combined_sources_step.add(output_files_step_tree)
    s1 = combined_sources_step.transform RowExploder,
      [:subject, :proficiency_band],
      :proficiency_band_value,
      :elapercentlevel1,
      :elapercentlevel2,
      :elapercentlevel3,
      :elapercentlevel4,
      :elapercentlevelbasic,
      :mathpercentlevel1,
      :mathpercentlevel2,
      :mathpercentlevel3,
      :mathpercentlevel4,
      :mathpercentlevelbasic

    s1 = s1.transform HashLookup,
      :subject,
      {
        mathpercentlevel1: 5, 
        mathpercentlevel2: 5, 
        mathpercentlevel3: 5, 
        mathpercentlevel4: 5,
        mathpercentlevelbasic: 5,
        elapercentlevel1: 2, 
        elapercentlevel2: 2, 
        elapercentlevel3: 2, 
        elapercentlevelbasic: 2
      }

    s1 = s1.transform HashLookup,
      :proficiency_band,
      {
        mathpercentlevel1: 183,
        mathpercentlevel2: 184,
        mathpercentlevel3: 186,
        mathpercentlevel4: 187,
        mathpercentlevelbasic: 185,
        elapercentlevel1: 183,
        elapercentlevel2: 184,
        elapercentlevel3: 186,
        elapercentlevel4: 187,
        elapercentlevelbasic: 185
      }

    s1.destination CsvDestination, '/Users/samson/Desktop/test_wa.tsv'

    s1.transform ColumnSelector, :schoolyear, :buildingnumber, :gradetested, :elatotaltested,
                 :elapercentlevel1, :elapercentlevel2, :elapercentlevelbasic, :elapercentlevel3,
                 :elapercentlevel4, :mathtotaltested, :mathpercentlevel1, :mathpercentlevel2,
                 :mathpercentlevelbasic, :mathpercentlevel3, :mathpercentlevel4

    column_order = [
        :year,
        :state_id,
        :grade,
        :elatotaltested,
        :elapercentlevel1,
        :elapercentlevel2,
        :elapercentlevelbasic,
        :elapercentlevel3,
        :elapercentlevel4,
        :mathtotaltested,
        :mathpercentlevel1,
        :mathpercentlevel2,
        :mathpercentlevelbasic,
        :mathpercentlevel3,
        :mathpercentlevel4,
    ]

    s1.transform(
        HashLookup,
        :schoolyear,
        {
            '2014-15' => '2015'
        }, to: :year
    )

    s1.transform MultiFieldRenamer, {
        buildingnumber: :state_id,
        gradetested: :grade
    }

    source_steps.each do |step|
      step.run
    end
  end

  def source_steps
    @_source_steps ||= (
      source_file_1 = '/Users/samson/Development/data/wa/2_23_SBA Scores by School_01.txt'
      source_file_2 = '/Users/samson/Development/data/wa/School_SBA_Scores_by_Subgroup_1_01.txt'

      source1 = CsvSource.new(source_file_1, col_sep: "\t")
      source1.event_log = self.event_log

      source2 = CsvSource.new(source_file_2, col_sep: "\t")
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

file = '/tmp/test_wa.txt'

output_files = {
  state: '/tmp/wa.2015.1.public.charter.state.txt',
  school: '/tmp/wa.2015.1.public.charter.school.txt',
  district: '/tmp/wa.2015.1.public.charter.district.txt',
  unique_values: '/tmp/wa.2015.unique_files.txt'
}

WATestProcessor.new(file, output_files).run



