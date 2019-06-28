require_relative "../test_processor"

class RITestProcessor2016PARCCNECAP < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end

  map_breakdown = {
    'All Students' => 1,
    'Black or African American' => 17,
    'Race/Ethnicity: Black or African American(non-Hispanic)' => 17,
    'Asian' => 16,
    'Race/Ethnicity: Asian(non-Hispanic)' => 16,
    'American Indian or Alaska Native' => 18,
    'Race/Ethnicity: American Indian or Alaskan Native(non-Hispanic)' => 18,
    'Hispanic or Latino' => 19,
    'Race/Ethnicity: Hispanic or Latino' => 19,
    'Native Hawaiian or Other Pacific Islander' => 20,
    'Race/Ethnicity: Native Hawaiian or Pacific Islander (non-Hispanic)' => 20,
    'White' => 21,
    'Race/Ethnicity: White (non-Hispanic)' => 21,
    'Two or More races' => 22,
    'Race/Ethnicity: Multi-Racial Non-hispanic' => 22,
    'Economically Disadvantaged' => 23,
    'SES: Economically Disadvantaged Students' => 23,
    'Other than Econ Disadvantaged' => 24,
    'SES: All Other Students' => 24,
    'Students with Disabilities' => 27,
    'IEP: Students with an IEP' => 27,
    'Other than Students with Disabilities' => 30,
    'IEP: All Other Students' => 30,
    'Males' => 25,
    'Gender: Male' => 25,
    'Females' => 26,
    'Gender: Female' => 26
  }

  map_breakdown_codes ={
    '0' => 'All Students',
    '1' => 'Gender: Male',
    '2' => 'Gender: Female',
    '4' => 'Race/Ethnicity: Hispanic or Latino',
    '5' => 'Race/Ethnicity: American Indian or Alaskan Native(non-Hispanic)',
    '6' => 'Race/Ethnicity: Asian(non-Hispanic)',
    '7' => 'Race/Ethnicity: Black or African American(non-Hispanic)',
    '8' => 'Race/Ethnicity: Native Hawaiian or Pacific Islander (non-Hispanic)',
    '9' => 'Race/Ethnicity: White (non-Hispanic)',
    '10' => 'Race/Ethnicity: Multi-Racial Non-hispanic',
    '16' => 'IEP: Students with an IEP',
    '17' => 'IEP: All Other Students',
    '18' => 'SES: Economically Disadvantaged Students',
    '19' => 'SES: All Other Students'
  }

  map_academic = {
    'Math' => 5,
    'ELA' => 4,
    'ALG01' => 6,
    'ALG02' => 10,
    'GEO01' => 8,
    'sci' => 19
  }

  map_prof_band_id = {
    percent_level_1: 13,
    percent_level_2: 14,
    percent_level_3: 15,
    percent_level_4: 16,
    percent_level_5: 17,
    percent_proficient_4_and_5: 1,
    p4: 8,
    p3: 7,
    p2: 6,
    p1: 5,
    p_3_and_4: 1
  }

  source("PARCC_2016.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school',
      year: 2016,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'RI PARCC',
      gsdata_test_data_type_id: 205,
      notes: 'DXT-2437: RI RI PARCC',
      description: 'The 2015-16 results of the Partnership for Assessment of Readiness for College and Careers (PARCC) assessments provide a first look at whether students are meeting the expectations of the new learning standards in literacy and mathematics. The PARCC exam is administered in grades 3 through 11 for English Language Arts, grades 3 through 8 for Math, and to students who took Algebra I, Algebra II and Geometry. These standards are designed to prepare students for success in their next grade level, in postsecondary learning, and in career opportunities.'
    })
    .transform("Rename Columns", MultiFieldRenamer,
      {
        schoolname: :school_name,
        group_name: :breakdown,
        school_code: :state_id
      })
    .transform("delete suppressed data",DeleteRows,:number_tested,'*',nil)
    .transform("delete suppressed data",DeleteRows,:number_tested,'0','1','2','3','4','5','6','7','8','9')
    .transform("delete bad breakdowns",DeleteRows,:breakdown,'LEP Monitored Year 1','LEP Monitored Year 2','Other than ELL','English Langauage Learner','LEP Monitored')
    .transform("correct subject grade values",WithBlock) do |row|
      if row[:testcode] == 'ELA'
        row[:subject] = 'ELA'
        row[:grade] = 'All'
      elsif row[:testcode] == 'MATH'
        row[:subject] = 'Math'
        row[:grade] = 'All'
      elsif row[:testcode].to_s.include?("ELA0")
        row[:subject] = 'ELA'
        row[:grade] = row[:testcode].gsub("ELA0","")
      elsif row[:testcode].to_s.include?("ELA")
        row[:subject] = 'ELA'
        row[:grade] = row[:testcode].gsub("ELA","")
      elsif row[:testcode].to_s.include?("MAT0")
        row[:subject] = 'Math'
        row[:grade] = row[:testcode].gsub("MAT0","")
      elsif row[:testcode].to_s.include?("MAT")
        row[:subject] = 'Math'
        row[:grade] = row[:testcode].gsub("MAT","")
      else
        row[:subject] = row[:testcode]
        row[:grade] = 'All'
      end
      row
    end
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_academic, to: :academic_gsdata_id)
    .transform("transposing band columns",Transposer,:proficiency_band,:value_float,:percent_level_1,:percent_level_2,:percent_level_3,:percent_level_4,:percent_level_5,:percent_proficient_4_and_5)      
    .transform("Adding column gsdata proficiency band from band", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_gsdata_id)
  end

  source("NECAP_2016.txt",[], col_sep: "\t") do |s|
    s.transform("Rename Columns", MultiFieldRenamer,
      {
        ntested: :number_tested
      })
    .transform('Fill missing default fields', Fill, {
      year: 2016,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      test_data_type: 'NECAP',
      gsdata_test_data_type_id: 191,
      notes: 'DXT-2437: RI NECAP',
      description: 'In 2015-16 Rhode Island used the New England Common Assessment Program (NECAP) to test students in grades 4, 8 and 11 in science. The NECAP is a standards-based test, which means it measures specific skills defined for each grade by the state of Rhode Island. The goal is for all students to score at or above the proficient level.'
      })
    .transform("delete suppressed data",DeleteRows,:number_tested,'0','1','2','3','4','5','6','7','8','9')
    .transform("Adding column breakdown from breadown code in file", HashLookup, :reporder, map_breakdown_codes, to: :breakdown)
    .transform("delete bad breakdowns",DeleteRows,:breakdown,nil)
    .transform("create prof above",WithBlock) do |row|
      row[:p_3_and_4] = row[:p3].to_f + row[:p4].to_f
      row
    end
    .transform("creating state_id",WithBlock) do |row|
      if row[:replevel] == 'sch'
        row[:entity_level] = 'school'
        row[:state_id] = row[:schcode].rjust(5,'0')
        row[:school_name] = row[:schname]
      elsif row[:replevel] == 'dis'
        row[:entity_level] = 'district'
        row[:state_id] = row[:discode].rjust(2,'0')
        row[:district_name] = row[:disname]
      elsif row[:replevel] == 'sta'
        row[:entity_level] = 'state'
      end
      row
    end
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_academic, to: :academic_gsdata_id)
    .transform("transposing band columns",Transposer,:proficiency_band,:value_float,:p1,:p2,:p3,:p4,:p_3_and_4)
    .transform("Adding column gsdata proficiency band from band", HashLookup, :proficiency_band, map_prof_band_id, to: :proficiency_band_gsdata_id)
  end

  def config_hash
    {
        gsdata_source_id: 44,
        state: 'ri',
        source_name: 'Rhode Island Department of Education',
        date_valid: '2016-01-01 00:00:00',
        url: 'Mary-Jane.James@ride.ri.gov',
        file: 'ri/2016/ri.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

RITestProcessor2016PARCCNECAP.new(ARGV[0], max: nil).run
