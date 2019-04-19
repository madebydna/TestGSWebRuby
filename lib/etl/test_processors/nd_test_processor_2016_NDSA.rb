require_relative "../test_processor"

class NDTestProcessor2016NDSA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2016
  end


  map_nd_breakdown = {
    'All' => 1,
    'Black' => 17,
    'Native American' => 18,
    'Asian American' => 16,
    'White' => 21,
    'Low Income' => 23,
    'English Learner' => 32,
    'Female' => 26,
    'Hispanic' => 19,
    'Male' => 25,
    'IEP (student with disabilities)' => 27,
    'Native Hawaiian or Pacific Islander' => 20,
    'Non-English Learner' => 33,
    'Non-IEP' => 30,
    'Non-Low Income' => 24,
  }

  map_nd_subject = {
    'Reading' => 2,
    'Math' => 5,
    'Science' => 19
  }

  source("School_Level_NDSA_16.txt",[], col_sep: "\t") do |s|
    s.transform("Fill values", Fill,{
    entity_level: 'school'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
     entity_name: :school_name
    })
 end

  source("District_Level_NDSA_16.txt",[], col_sep: "\t") do |s|
   s.transform("Fill values", Fill,{
    entity_level: 'district'
    })
   .transform('Rename column headers', MultiFieldRenamer,{
     entity_name: :district_name
    })
 end

  source("State_Level_NDSA_16.txt",[], col_sep: "\t") do |s|
   s.transform("Fill values", Fill,{
    entity_level: 'state'
    })
  end

 shared do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'public_charter',
      level_code: 'e,m,h',
      proficiency_band_gsdata_id: 1,
      proficiency_band: 'proficient and above',
      test_data_type: 'NDSA',
      gsdata_test_data_type_id: 206,
      year: 2016,
      description: 'In 2015-16, North Dakota used the North Dakota State Assessment (NDSA) to test students in grades 3 through 8 and 11 in reading and math, and in science in grades 4, 8 and 11. Results represent students enrolled in the school for the entire academic year. The NDSA is a standards-based test, which means it measures how well students are mastering the specific skills defined for each grade by the state of North Dakota. The goal is for all students to score at or above the proficient level.',
      notes: 'DXT-3040: ND 2016 NDSA'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      subgroup_desc: :breakdown,
      grades: :grade,
      total_students: :number_tested,
      entity_id: :state_id
    })
    .transform("Skip bad subgroups", DeleteRows, :breakdown, 'All Others', 'Migrant', 'Non-Migrant')
    .transform("Adding column breakdown_id from group",
      HashLookup, :breakdown, map_nd_breakdown, to: :breakdown_gsdata_id)
    .transform("Filling in subject ids",
    HashLookup, :subject, map_nd_subject, to: :academic_gsdata_id)
    .transform("Fixing grade All name", WithBlock) do |row|
     if row[:grade] =~ /All Grades/
       row[:grade] = 'All'
     else row[:grade] = row[:grade]
     end
     row
   end
   .transform("Delete rows where number tested is less than 10 and blank ",DeleteRows, :number_tested, '0','1','2','3','4','5','6','7','8','9')
   .transform("Calc prof and above, ignore missing values", WithBlock) do |row|
      if !(row[:pct_students_proficient] =~ /\-/ && row[:pct_students_advanced] =~ /\-/)
        row[:value_float] = row[:pct_students_proficient].to_f+row[:pct_students_advanced].to_f
        row[:value_float] = 100*row[:value_float]
      elsif !(row[:pct_students_novice] =~ /\-/ && row[:pct_students_partially_proficient] =~ /\-/)
        row[:value_float] = 1 - row[:pct_students_novice].to_f - row[:pct_students_partially_proficient].to_f
        row[:value_float] = 100*row[:value_float]
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
   .transform("Creating StateID for schools and state", WithBlock) do |row|
     if row[:entity_level] == 'school'
        row[:school_id] = row[:state_id]
        if row[:school_type] == 'Middle'
          row[:state_id] = row[:state_id] + '2'
        elsif row[:school_type] == 'Elementary'
          row[:state_id] = row[:state_id] + '1'
        elsif row[:school_type] == 'Secondary'
          row[:state_id] = row[:state_id] + '3'
        end
        row[:state_id] = row[:state_id].rjust(10,'0')
     elsif row[:entity_level] == 'district'
        row[:district_id] = row[:state_id]
        row[:state_id] = row[:state_id].rjust(5,'0')
     elsif row[:entity_level] == 'state'
        row[:state_id] = 'state'
     end
     row
    end
  end



  def config_hash
    {
        gsdata_source_id: 38,
        state: 'nd',
        source_name: 'North Dakota Department of Public Instruction',
        date_valid: '2016-01-01 00:00:00',
        url: 'https://insights.nd.gov/Data',
        file: 'nd/2016/output/nd.2016.1.public.charter.[level].txt',
        level: nil,
        school_type: 'public,charter'
    }
  end
end

NDTestProcessor2016NDSA.new(ARGV[0], max: nil).run