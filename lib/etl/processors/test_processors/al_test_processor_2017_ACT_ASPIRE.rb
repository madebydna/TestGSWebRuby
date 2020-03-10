require_relative "../test_processor"

class ALTestProcessor2017ACTASPIRE < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  map_gsdata_breakdown = {
    'All Students' => 1,
     'Black' => 17,
     'Hispanic/Latino' => 19,
     'Asian' => 16,
     'White' => 21,
     'American Indian/Alaskan Native' => 18,
     'Native Hawaiian/Pacific Islander' => 20,
     '2 or More Races' => 22,
     'Poverty' => 46,
     'Non-Poverty' => 47,
     'English Learner' => 32,
     'Non-English Learner' => 33,
    'Special Education Students' => 27,
    'General Education Students' => 30,
     'Female' => 26,
     'Male' => 25
  }

  map_gsdata_academic = {
    'Reading' => 2,
    'Math' => 5,
    'Science' => 19
  }

  source("grade_03.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '3'
    })
  end
  source("grade_04.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '4'
    })
  end
    source("grade_05.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '5'
    })
  end
    source("grade_06.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '6'
    })
  end
    source("grade_07.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '7'
    })
  end
    source("grade_08.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '8'
    })
  end
    source("grade_10.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      grade: '10'
    })
  end

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'ACT Aspire',
      proficiency_band_gsdata_id: 1,
      proficiency_band: 'proficient and above',
      gsdata_test_data_type_id: 262,
      notes: 'DXT-2720: AL ACT Aspire',
      description: 'In 2016-2017, students in Alabama took the ACT Aspire. The ACT Aspire is a standards-based assessment system that gauges student progression from grades 3-8, and grade 10 in english and math, and grades 5, 7, and 10 in science. The ACT Aspire is administered to grades 3-8 and grade 10 students in Alabama public schools.'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
    system_name: :district_name,
    system_code: :district_id,
    school_code: :school_id,
    subpopulation: :breakdown,
    })
    .transform("Skip missing values", DeleteRows, :tested_percentage, '*')
    .transform("Skip migrant and nonmigrant", DeleteRows, :breakdown, 'Migrant', 'Non-Migrant')
    .transform("Calc prof and above, ignore missing values", WithBlock) do |row|
      if row[:ready_percentage] =~ /^\d/ && row[:exceeding_percentage] =~ /^\d/
        row[:value_float] = row[:ready_percentage].to_f+row[:exceeding_percentage].to_f
      elsif row[:in_need_of_support_percentage] =~ /^\d/ && row[:close_percentage] =~ /^\d/
        row[:value_float] = 100 - row[:in_need_of_support_percentage].to_f - row[:close_percentage].to_f
      end
      row
    end
    .transform("fix special cases for prof and above", WithBlock) do |row|
          if row[:value_float].nil?
            row[:value_float]=row[:value_float]
          elsif row[:value_float] < 0
            row[:value_float] = 0
          elsif row[:value_float] > 100
            row[:value_float] = 100
          elsif row[:value_float].between?(0,1)
            row[:value_float]=row[:value_float].round(2)
          end
     row
    end
    .transform("Skip missing prof and above values", DeleteRows, :value_float, nil)
    .transform("Assign entity level", WithBlock) do |row|
      if row[:school_id] == '0000' && row[:district_id] == '000'
        row[:entity_level] = 'state'
      elsif row[:school_id] == '0000'
        row[:entity_level] = 'district'
      else
        row[:entity_level] = 'school'
      end
      row
    end
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
    .transform('Set up state_id',WithBlock) do |row|
      row[:entity_level] = row[:entity_level].downcase()
      if row[:entity_level] == 'school'
        row[:state_id] = row[:district_id] + row[:school_id]  
      elsif row[:entity_level] == 'district'
        row[:state_id] = row[:district_id]
      else
        row[:state_id] = 'state'
      end
      row
    end
  end

  def config_hash
    {
        gsdata_source_id: 4,
        state: 'al',
        source_name: 'Alabama Department of Education',
        date_valid: '2017-01-01 00:00:00',
        url: 'http://www.alsde.edu',
        file:'al/2017/al.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

ALTestProcessor2017ACTASPIRE.new(ARGV[0], max: nil).run