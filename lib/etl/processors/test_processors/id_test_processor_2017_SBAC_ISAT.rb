require_relative "../test_processor"

class IDTestProcessor2017SBACISAT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  map_breakdown = {
    'All Students' => 1,
    'Black / African American' => 17,
    'Asian or Pacific Islander' => 15,
    'American Indian or Alaskan Native' => 18,
    'Hispanic or Latino' => 19,
    'Native Hawaiian / Other Pacific Islander' => 20,
    'White' => 21,
    'Two Or More Races' => 22,
    'LEP' => 32,
    'Not LEP' => 33,
    'Economically Disadvantaged ' => 23,
    'Not Economically Disadvantaged' => 24,
    'Students with Disabilities ' => 27,
    'Students without Disabilities' => 30,
    'Male' => 25,
    'Female' => 26
  }

  map_academic = {
    'Math' => 5,
    'ELA' => 4,
    'Science' => 19
  }

  source("schools.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'school'
    })
    .transform("Rename Columns", MultiFieldRenamer,
      {
        schoolname: :school_name
      })
    .transform("Create school state_ids",WithBlock) do |row|
      row[:state_id] = row[:districtid] + row[:schoolid]
      row
    end
  end

  source("districts.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'district'
    })
    .transform("Rename Columns", MultiFieldRenamer,
      {
        districtname: :district_name
      })
    .transform("Create district state_id",WithBlock) do |row|
      row[:state_id] = row[:districtid]
      row
    end
  end

  source("state.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_level: 'state'
    })
  end

  shared do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band: 'prof_above',
      proficiency_band_gsdata_id: 1,
      })
    .transform("Rename columns", MultiFieldRenamer,
      {
        subjectname: :subject,
        populationname: :breakdown,
        gradelevel: :grade
      })
    .transform("assign tests",WithBlock) do |row|
      if row[:subject] == 'Math' || row[:subject] == 'ELA'
        row[:test_data_type] = 'ID SBAC'
        row[:gsdata_test_data_type_id] = 198
        row[:notes] = 'DXT-2995: ID ID SBAC'
        row[:description] = 'In 2016-2017, students in grades 3-8 and once in high school take the SBAC to determine whether they have achieved the standards for their grade level and subject area. There are tests for English Language Arts/Literacy and Mathematics.'
      elsif row[:subject] == 'Science'
        row[:test_data_type] = 'ISAT'
        row[:gsdata_test_data_type_id] = 197
        row[:notes] = 'DXT-2995: ID ISAT'
        row[:description] = 'In 2016-2017, students in grades 5 and 7, students took the ISAT science assessment.'
      end
      row
    end
    .transform("Calculate proficient and above",WithBlock) do |row|
      if row[:advanced].tr("%","") != '***' && row[:proficient].tr("%","") != '***'
        row[:value_float] = row[:advanced].tr("%","").to_f + row[:proficient].tr("%","").to_f
      elsif row[:basic].tr("%","") != '***' && row[:belowbasic].tr("%","") != '***'
        row[:value_float] = 100 - row[:basic].tr("%","").to_f - row[:belowbasic].tr("%","").to_f
      else row[:value_float] = 'skip'
      end
      row
    end
    .transform("delete bad data",DeleteRows,:value_float,'skip')
    .transform("delete bad breakdowns",DeleteRows,:breakdown,'At-Risk','Not At-Risk','Migrant','Homeless')
    .transform("delete bad grades",DeleteRows,:grade,'High School')
    .transform("correct grade values",WithBlock) do |row|
      if row[:grade].include?("Grade ")
        row[:grade] = row[:grade].gsub("Grade ","")
      elsif row[:grade].include?(" Grades")
        row[:grade] = row[:grade].gsub(" Grades","")
      end
      row
    end
    .transform("Adding column gsdata breakdown_id from breadown", HashLookup, :breakdown, map_breakdown, to: :breakdown_gsdata_id)
    .transform("Adding column gsdata academics_id from subject", HashLookup, :subject, map_academic, to: :academic_gsdata_id)
  end

  def config_hash
    {
        gsdata_source_id: 16,
        state: 'id',
        source_name: 'Idaho State Department of Education',
        date_valid: '2017-01-01 00:00:00',
        url: 'http://www.sde.idaho.gov/assessment/accountability/index.html',
        file: 'id/2017/id.2017.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

IDTestProcessor2017SBACISAT.new(ARGV[0], max: nil).run
