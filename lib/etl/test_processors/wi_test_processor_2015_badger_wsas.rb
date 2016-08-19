require_relative "../test_processor"

class WITestProcessor2015BadgerWsas < GS::ETL::TestProcessor
  #GS::ETL::Logging.disable

  def initialize(*args)
    super
    @year = 2015
  end

  wsas_prof_id_map={
    'Minimal Performance' => 14,
    'Basic' => 15,
    'Proficient' => 16,
    'Advanced' => 17
  }

  badger_prof_id_map={
    'Below Basic' => 78,
    'Basic' => 79,
    'Proficient' => 80,
    'Advanced' => 81
  }
  source("wsas_current_2014-15_final.txt",[], col_sep: "\t") do |s|
    s.transform("Create test_data_type, test_data_type_id cols", Fill, {test_data_type: "wsas", test_data_type_id: 160})
    .transform("Rename prof column", MultiFieldRenamer, {test_result: :proficiency_band})
    .transform("Lookup prof ids", HashLookup, :proficiency_band, wsas_prof_id_map, to: :proficiency_band_id)
  end

  source("badger_current_2014-15_final.txt",[], col_sep: "\t") do |s|
  s.transform("Create test_data_type, test_data_type_id cols", Fill, {test_data_type: "badger", test_data_type_id: 307})
  .transform("Rename prof column", MultiFieldRenamer, {test_result: :proficiency_band})
  .transform("Lookup prof ids", HashLookup, :proficiency_band, badger_prof_id_map, to: :proficiency_band_id)
  end

  breakdown_id_map={
    'All Students' => 1,
    'Amer Indian' => 4,
    'Black' => 3,
    'Hispanic' => 6,
    'White' => 8,
    'Two or More' => 21,
    'Pacific Isle' => 7,
    'Asian' => 2,
    'Female' => 11,
    'Male' => 12,
    'Not Econ Disadv' => 10,
    'Econ Disadv' => 9,
    'SwD' => 13,
    'SwoD' => 14,
    'ELL/LEP' => 15,
    'Eng Prof' => 16,
    'Migrant' => 19,
    'Not Migrant' => 28
  }

  subject_id_map={
    'ELA' => 4,
    'Mathematics' => 5,
    'Science' => 25,
    'Social Studies' => 24
  }


  shared do |s|
    s.transform("Format year correctly", WithBlock) do |row|
      row[:school_year].gsub!('14-','')
      row
    end
    .transform("Remove alternative assessments", DeleteRows, :test_group, "WAA-SwD","DLM")
    .transform("Remove Unkown breakdown", DeleteRows, :group_by_value, "Unknown")
    .transform("Remove suppressed rows", DeleteRows, :percent_of_group, "*")
    .transform("Rename columns",MultiFieldRenamer,
    {
      district_code: :district_id,
      school_code: :school_id,
      school_year: :year,
      test_subject: :subject,
      grade_level: :grade,
      group_by_value: :breakdown,
      new_prof: :value_float
      })
    .transform("Create state_id, entity cols", WithBlock) do |row|
      if row[:district_name]=="[Statewide]"
        row[:school_name]='state'
        row[:school_id]='state'
        row[:district_name]='state'
        row[:district_id]='state'
        row[:state_id]='state'
        row[:entity_level]='state'
      elsif row[:school_name]=="[Districtwide]"
        row[:school_name]='district'
        row[:school_id]='district'
        row[:district_id]=row[:district_id].rjust(4,'0')
        row[:state_id]=row[:district_id].rjust(4,'0')
        row[:entity_level]='district'
      else
        row[:state_id]=row[:district_id].rjust(4,'0')+row[:school_id].rjust(4,'0')
        row[:entity_level]='school'
      end
      row
    end
    .transform("Lookup breakdown ids", HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
    .transform('Look up subject ids', HashLookup, :subject, subject_id_map, to: :subject_id)
    .transform("Fill default columns", Fill, {
      entity_type: 'public,charter',
      level_code: 'e,m,h'
      })
    .transform("Add up proficient and above", SumProficiencyBands,['Proficient','Advanced'])
    .transform("Remove rows with number tested <10",WithBlock) do |row|
      row if row[:number_tested].to_f>=10
    end
    .transform("Fix rounding errors",WithBlock) do |row|
      row[:value_float]=100 if row[:value_float].to_f==100.01
    end
      # .transform("",WithBlock) do |row|
      #   require 'byebug'
      #   byebug
      #
      #   row
      # end
  end

  def config_hash
    {
        source_id: 25,
        state: 'wi',
        notes: 'DXT-1712: WI Badger and WSAS 2015',
        url: 'http://wisedash.dpi.wi.gov/Dashboard/portalHome.jsp',
        file: 'wi/2015/output/newdatatools/wi.2015.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

WITestProcessor2015BadgerWsas.new(ARGV[0], offset: nil, max: nil).run
