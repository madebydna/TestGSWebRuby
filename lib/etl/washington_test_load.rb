$LOAD_PATH.unshift File.dirname(__FILE__)
require 'etl'
require 'event_log'
require 'sources/csv_source'
require 'destinations/csv_destination'
require 'transforms/column_selector'

class WATestProcessor < GS::ETL::DataProcessor
  def initialize(source_file, output_file)
    @source_file = source_file
    @output_file = output_file
  end

  def run
    s1 = source CsvSource, @source_file, col_sep: "\t"
    # require 'pry'; binding.pry

    # s1.transform ColumnSelector, :test_year, :state_id, :county_code, :district_code,
    #              :school_code, :subgroup_id, :test_type, :test_id, :grade, :students_tested,
    #              :percentage_standard_exceeded, :percentage_standard_met, :percentage_standard_nearly_met,
    #              :percentage_standard_not_met

    column_order = [
        :schoolyear,
        :esd,
        :countynumber,
        :county,
        :countydistrictnumber,
        :district,
        :buildingnumber,
        :school,
        :gradetested,
        :elatotaltestednottested,
        :elatotaltestednil,
        :elametstandardincludingprevpassnil,
        :elapercentmetstandardincludingprevpassnil,
        :elametstandardwithoutprevpassnil,
        :elapercentmetstandardwithoutprevpassnil,
        :elapercentmetstandardexcludingnoscorenil,
        :elalevel1nil,
        :elapercentlevel1nil,
        :elalevel2nil,
        :elapercentlevel2nil,
        :elalevelbasicnil,
        :elapercentlevelbasicnil,
        :elalevel3nil,
        :elapercentlevel3nil,
        :elalevel4nil,
        :elapercentlevel4nil,
        :elanoscorenil,
        :elapercentnoscorenil,
        :elanotmetnil,
        :elapercentnotmetnil,
        :elaexcusedabsencenil,
        :elaexemptednil,
        :elawaasportnil,
        :elawaasdapenil,
        :mathtotaltestednottested,
        :mathtotaltestednil,
        :mathmetstandardincludingprevpassnil,
        :mathpercentmetstandardincludingprevpassnil,
        :mathmetstandardwithoutprevpassnil,
        :mathpercentmetstandardwithoutprevpassnil,
        :mathpercentmetstandardexcludingnoscorenil,
        :mathlevel1nil,
        :mathpercentlevel1nil,
        :mathlevel2nil,
        :mathpercentlevel2nil,
        :mathlevelbasicnil,
        :mathpercentlevelbasicnil,
        :mathlevel3nil,
        :mathpercentlevel3nil,
        :mathlevel4nil,
        :mathpercentlevel4nil,
        :mathnoscorenil,
        :mathpercentnoscorenil,
        :mathnotmetnil,
        :mathpercentnotmetnil,
        :mathexcusedabsencenil,
        :mathexemptednil,
        :mathwaasportnil,
        :mathwaasdapenil,
        :elalevelindexnil,
        :mathlevelindexnil
    ]

    s1.destination CsvDestination, @output_file, *column_order
    s1.root.run
    # require 'pry'; binding.pry
  end
end

file = '/vagrant/GSWebRuby/tmp/wa_2_23_SBA_ScoresBySchool_Sample.txt'
output_file = '/vagrant/GSWebRuby/tmp/new_wa_test_file_.tsv'

WATestProcessor.new(file, output_file).run
