require_relative "../test_processor"

class NETestProcessor20172018NSCASNESA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end

  breakdown_id_map = {
      "All students" => 1,
      "Black or African American" => 17,
      "American Indian/Alaska Native" => 18,
      "Asian" => 16,
      "White" => 21,
      "Hispanic" => 19,
      "Two or More Races" => 22,
      "Female" => 26,
      "Male" => 25,
      "English Language Learners" => 32,
      "Native Hawaiian or Other Pacific Islander" => 20,
      "Students eligible for free and reduced lunch" => 23,
      "Special Education Students" => 27
  }

  source("math.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      subject_id: 5,
      test_data_type: 'NESA',
      test_data_type_id: 217,
      notes: 'DXT-3128: NE NESA'
    })
   # .transform('Filter to correct year', KeepRows, :"School Year", '2016-2017')
  end
#   source("NeSA_Science_Proficient_20162017.txt",[], col_sep: "\t") do |s|
#     s.transform('Fill missing default fields', Fill, {
#       year: 2017,
#       date_valid: '2017-01-01 00:00:00',
#       subject_id: 19,
#       test_data_type: 'NESA',
#       test_data_type_id: 217,
#       notes: 'DXT-3128: NE NESA'
#     })
#    # .transform('Filter to correct year', KeepRows, :"School Year", '2016-2017')
#   end

#   source("NSCAS_ELA_Proficient_20172018.txt",[], col_sep: "\t") do |s|
#     s.transform('Fill missing default fields', Fill, {
#       year: 2018,
#       date_valid: '2018-01-01 00:00:00',
#       subject_id: 4,
#       test_data_type: 'NSCAS',
#       test_data_type_id: 360,
#       notes: 'DXT-3128: NE NSCAS'
#     })
#    # .transform('Filter to correct year', KeepRows, :"School Year", '2017-2018')
#   end

#   source("NSCAS_Math_Proficient_20172018.txt",[], col_sep: "\t") do |s|
#     s.transform('Fill missing default fields', Fill, {
#       year: 2018,
#       date_valid: '2018-01-01 00:00:00',
#       subject_id: 5,
#       test_data_type: 'NSCAS',
#       test_data_type_id: 360,
#       notes: 'DXT-3128: NE NSCAS'
#     })
#    # .transform('Filter to correct year', KeepRows, :"School Year", '2017-2018')
#   end

#   source("NSCAS_Science_Proficient_20172018.txt",[], col_sep: "\t") do |s|
#     s.transform('Fill missing default fields', Fill, {
#       year: 2018,
#       date_valid: '2018-01-01 00:00:00',
#       subject_id: 19,
#       test_data_type: 'NSCAS',
#       test_data_type_id: 360,
#       notes: 'DXT-3128: NE NSCAS'
#     })
#     #.transform('Filter to correct year', KeepRows, :"School Year", '2017-2018')
#   end
# =end
  shared do |s| 
    s.transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      type: :entity_type,
      "Student Subgroup" => :breakdown
    })
    .transform('Set up entity_type',WithBlock) do |row|
      if row[:entity_type] == 'SC'
        row[:entity_type] = 'school'
      elsif row[:entity_type] == 'DI'
        row[:entity_type] = 'district'
      elsif row[:entity_type] == 'ST'
        row[:entity_type] = 'state'
      end
      row
    end
    .transform("byebug", WithBlock) do |row|
      require 'byebug'
      byebug
    end
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:County] + row[:District] + row[:School]
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:County] + row[:District] + "000"
      else
        row[:state_id] = 'state'
      end
      row
    end
    .transform("Skip invalid type", DeleteRows, :Type, 'LC')  
    .transform("Skip invalid values", DeleteRows, :"AVERAGE SCALE SCORE", '-1')    
    .transform('skip subgroups', DeleteRows, :breakdown, 'Highly Mobile Students', 'Foster Care', 'Homeless', 'Special Education Students - Alternate Assessment', 'Students served in migrant programs', 'Parent in Military')  
    .transform("Process prof and above", WithBlock) do |row|
      if row[:"Basic Pct"] == '-1'
        row[:value] = row[:"Proficient Pct"] + row[:"Advanced Pct"]
      elsif row[:"Proficient Pct"] == '-1' && row[:"Advanced Pct"] == '-1'
        row[:value] = 1 - row[:"Basic Pct"].to_f 
      end
      row
    end 
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Add test details', WithBlock) do |row|
      if row[:year] == 2017
        row[:description] = 'In 2016-2017 Nebraska used the Nebraska Student-Centered Assessment System (NSCAS) assessment to test students in grades 3 through 8 and 11 in english language arts. Nebraska also used the Nebraska State Accountability (NeSA) to test students in grades 3 through 8 and 11 in math, and in grades 5, 8 and 11 in science. These assessments are standards-based tests, which means it measures how well students are mastering specific skills defined for each grade by the state of Nebraska. The goal is for all students to score at or above proficient on the test.'
      elsif row[:year] == 2018
          row[:description] = 'In 2017-18 Nebraska used the Nebraska Student-Centered Assessment System (NSCAS) assessment to test students in grades 3 through 8 and 11 in english language arts and math, and grades 5, 8, and 11 in science. The NSCAS is a statewide assessment system that embodies Nebraska’s holistic view of students and helps them prepare for success in postsecondary education, career, and civic life.'
      end
      row
    end 
  end

  def config_hash
    {
        source_id: 31,
        state: 'ne'
    }
  end
end

NETestProcessor20172018NSCASNESA.new(ARGV[0], max: nil).run