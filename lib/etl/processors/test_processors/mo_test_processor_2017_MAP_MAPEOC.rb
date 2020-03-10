require_relative "../test_processor"

class MOTestProcessor2017MAP_MAPEOC < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  key_map_bd = {
    'Amer. Indian or Alaska Native' => 4,
    'Asian/Pacific Islander' => 22,
    'Black (not Hispanic)' => 3,
    'Hispanic' => 6,
    'Multiracial' => 21,
    'White (not Hispanic)' => 8,
    'LEP/ELL Students' => 15,
    'ELL Students' => 15,
    'IEP Students' => 13,
    'IEP_student' => 13,
    'Non IEP Students' => 14,
    'Map Free and Reduced Lunch' => 9,
    'Non Free and Reduced Lunch' => 10,
    'Total' => 1
  }

  map_gsdata_breakdown = {
    'Amer. Indian or Alaska Native' => 18,
    'Asian/Pacific Islander' => 15,
    'Black (not Hispanic)' => 17,
    'Hispanic' => 19,
    'Multiracial' => 22,
    'White (not Hispanic)' => 21,
    'LEP/ELL Students' => 32,
    'ELL Students' => 32,
    'IEP Students' => 27,
    'IEP_student' => 27,
    'Non IEP Students' => 30,
    'Map Free and Reduced Lunch' => 23,
    'Non Free and Reduced Lunch' => 24,
    'Total' => 1
  }
  
  key_map_sub = {
   'Eng. Language Arts' => 4,
   'Mathematics' => 5,
   'Science' => 25,
   'Social Studies' => 24,
   'E1' => 19,
   'A2' => 11,
   'AH' => 30,
   'B1' => 29,
   'PS' => 31,
   'GE' => 9,
   'GV' => 71,
  }
  
  map_gsdata_academic = {
   'Eng. Language Arts' => 4,
   'Mathematics' => 5,
   'Science' => 19,
   'Social Studies' => 18,
   'E1' => 17,
   'A2' => 10,
   'AH' => 23,
   'B1' => 22,
   'PS' => 24,
   'GE' => 8,
   'GV' => 56,
  }

  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state',
  })
  end

  source("district.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
       entity_level: 'district',
  })
  end

  source("school.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
       entity_level: 'school',
  })
  end

  shared do |s|
    s.transform("renaming fields",
      MultiFieldRenamer,
      {
        pro_null: :value_float,
        type: :breakdown,
        content_area: :subject,
        grade_level: :grade,
        reportable: :number_tested,
        school_code: :school_id,
        county_district: :district_id
      })
    .transform('fill missing default fields', Fill, {
        entity_type: 'public_charter',
        proficiency_band: 'null',
        proficiency_band_id: 'null',
        level_code: 'e,m,h',
        proficiency_band_gsdata_id: 1
    })
    .transform("delete old year data",DeleteRows, :year, '2015','2016')
    .transform("delete grade 11 data",DeleteRows, :grade, '11','',' ')
    .transform("delete breakdown",DeleteRows, :breakdown,'No Response','Gifted','High School Vocational','IEP MAPA','IEP Non MAPA','In Building < 1 year','In District < 1 year','LEP/ELL < 1 year in USA','LEP/ELL 1st - 3rd yr','LEP/ELL Monitoring','LEP/ELL Receiving Service','Migrant','TitleI','Super Subgroup')
    .transform("assign test/subject/grade", WithBlock) do |row|
      if row[:grade]=~/^[A-Z]/
        row[:subject] = row[:grade]
        row[:grade] = 'All'
        row[:test_data_type] = 'map eoc'
        row[:test_data_type_id] = 145
        row[:gsdata_test_data_type_id] = 229
        row[:notes] = 'DXT-2570 MO MAP EOC 2017'
        row[:description] = 'The 2016-2017 Missouri Assessment Program assesses students progress toward the Missouri Learning Standards, which are Missouri content standards. End-of-Course assessments are taken when a student has received instruction on the Missouri Learning Standards for an assessment, regardless of grade level. Missouri suite of available End-of-Course assessments includes: English I, English II, Algebra II, Geometry, American History, Government, Biology and Physical Science.'
      else
        row[:test_data_type] = 'map'
        row[:test_data_type_id] = 28
        row[:gsdata_test_data_type_id] = 228
        row[:notes] = 'DXT-2570 MO MAP 2017'
        row[:description] = 'The 2016-2017 Missouri Assessment Program assesses students progress toward mastery of the Show-Me Standards which are the educational standards in Missouri. The Grade-Level Assessment is a yearly standards-based test that measures specific skills defined for each grade by the state of Missouri. All students in grades 3-8 in Missouri will take the grade level assessment. English Language Arts and Mathematics are administered in all grades. Science is administered in grades 5 and 8.'
      end
      row
    end
    .transform("calculate result", WithBlock) do |row|
      if row[:advanced_pct] =~ /^[0-9]/ && row[:proficient_pct] =~ /^[0-9]/
        row[:value_float] = row[:advanced_pct].to_f + row[:proficient_pct].to_f
      elsif row[:basic_pct] =~ /^[0-9]/ && row[:below_basic_pct] =~ /^[0-9]/
        row[:value_float] = 100-(row[:basic_pct].to_f + row[:below_basic_pct].to_f)
      else
        row[:value_float] = '*'
      end

      if row[:value_float]=~ /^[0-9]/ and row[:value_float] < 0.1
        row[:value_float] = 0
      elsif row[:value_float]=~ /^[0-9]/ and row[:value_float] > 100
        row[:value_float] = 100
      end
      row
    end   
    .transform("delete no result",DeleteRows, :value_float, '*') 
    .transform("fix value", WithBlock) do |row|
      if row[:value_float] < 0.1
        row[:value_float] = 0
      elsif row[:value_float] > 100
        row[:value_float] = 100
      end
      row[:value_float] = row[:value_float].to_s
      row
    end  
    .transform("adding column breakdown_id from breadown", HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("adding column subject_id from subject", HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform('mapping breakdowns', HashLookup, :breakdown, map_gsdata_breakdown, to: :breakdown_gsdata_id)
    .transform('mapping subjects', HashLookup, :subject, map_gsdata_academic, to: :academic_gsdata_id)
    .transform("creating StateID", WithBlock) do |row|
      if row[:entity_level] == 'district'
        row[:state_id] = row[:district_id]
        row[:school_id] = nil
      elsif row[:entity_level] == 'school'
        row[:state_id] = row[:school_id]+row[:district_id]
        row[:school_id] = row[:state_id]
        row[:district_id] = nil
      else
        row[:school_id] = nil
        row[:district_id] = nil
      end
      row
    end
  end

  def config_hash
    {
        source_id: 12,
        state: 'mo',
        source_name: 'North Carolina Department of Public Instruction',
        date_valid: '2017-01-01 00:00:00',
        url: 'http://www.dese.state.mo.us/',
        file: 'mo/2017/output/mo.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

MOTestProcessor2017MAP_MAPEOC.new(ARGV[0], max: nil).run
