require_relative "../test_processor"

class FLTestProcessor2018FSA_EOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  key_map_bd = {
    'All' => 1,
    '1-White' => 21,
    '2-Hispanic' => 19,
    '3-Black' => 17,
    '4-Two or More Races' => 22,
    '5-Asian' => 16,
    '6-American Indian' => 18,
    '7-Pacific Islander' => 37,
    'Eco. Disadvantaged' => 23,
    'Disabled' => 27,
    'ELL' => 32,
    'Non-Disabled' => 30,
    'Non-Eco. Disadvantaged' => 24,
    'Non-ELL' => 33
  }

  key_map_sub = {
    'Alg 1' => 6,
    'Biology' => 22,
    'Civics' => 68,
    'ELA' => 4,
    'Geo' => 8,
    'Geometry' => 8,
    'Math' => 5,
    'Science' => 19,
    'US History' => 23
  }

  source("fl_school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
  end

  source("fl_district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
  end

  source("fl_state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        subgroup: :breakdown,
        Grade: :subject,
        number: :number_tested,
        percent: :value_float
      })
    .transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band_gsdata_id: 1
    })
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_gsdata_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :academic_gsdata_id)
    .transform("Map Test Type", WithBlock) do |row|
      if row[:subject] == 'ELA' || row[:subject] == 'Math'
        row[:test_data_type] = 'FSA'
        row[:gsdata_test_data_type_id] = 307
        row[:notes] ='DXT-2835: FL FSA'
        row[:description] = 'In 2017-2018, the Florida Standards Assessments (FSA) tested students in English Language Arts (ELA) and Mathematics.'
      else
        row[:test_data_type] = 'FLEOC'
        row[:gsdata_test_data_type_id] = 306
        row[:notes] ='DXT-2835: FL FLEOC'
        row[:description] = 'In 2017-2018, the FL End-of-Course (EOC) assessment tested students in various subjects like Algebra 1 and US History.'
      end
    row
    end
    .transform("remove commas from number tested",WithBlock) do |row|
      row[:number_tested] = row[:number_tested].gsub(",","")
    row
    end
    .transform("remove perc sign from value", WithBlock) do |row|
      row[:value_float] = row[:value_float].gsub("%","")
    row
    end
    .transform("remove 0 padding from grades",WithBlock) do |row|
      row[:grade] = row[:grade].sub(/^0/,"")
    row
    end
  end


  def config_hash
    {
        gsdata_source_id: 12,
        state: 'fl',
        source_name: 'Florida Department of Education',
        date_valid: '2018-01-01 00:00:00',
        url: 'https://edstats.fldoe.org/SASPortal/main.do',
        file: 'fl/2018/output/fl.2018.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

FLTestProcessor2018FSA_EOC.new(ARGV[0], max: nil).run
