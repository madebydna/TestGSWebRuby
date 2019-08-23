require_relative "../test_processor"

class AZTestProcessor2017AIMSAZMERIT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
  end

  breakdown_id_map = {
      "All Students" => 1,
      "American Indian/Alaska Native" => 18,
      "Female" => 26,
      "Male" => 25,
      "Asian" => 16,
      "White" => 21,
      "Hispanic/Latino" => 19,
      "Native Hawaiian/Other Pacific Islander" => 20,
      "Students with Disabilities" => 27,
      "Two or More Races" => 22,     
      "African American" => 17,
      "Limited English Proficient" => 32,
      "Economic Disadvantage" => 23,
      "Economically Disadvantaged" => 23     
  }

  subject_id_map = {
    'Science' => 19,
    'Math' => 5,
    'English Language Arts' => 4,
    'Algebra I' => 6,
    'Algebra II' => 10,
    'Geometry' => 8
   }

  source("state_merit.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'state',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2016-2017, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8, and grade 11. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3090: AZ AZMerit'
    })
  end
  source("state_aims.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'state',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2016-2017, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards. on the test.',
      notes: 'DXT-3090: AZ AIMS'
    })
  end
  source("district_merit.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2016-2017, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8, and grade 11. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3090: AZ AZMerit'
    })
  end
  source("district_aims.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'district',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2016-2017, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards. on the test.',
      notes: 'DXT-3090: AZ AIMS'
    })
  end
  source("school_merit.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2016-2017, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8, and grade 11. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3090: AZ AZMerit'
    })
  end
  source("school_aims.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      entity_type: 'school',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2016-2017, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards. on the test.',
      notes: 'DXT-3090: AZ AIMS'
    })
  end
  
  shared do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      school_number: :school_name,
      subgroup_ethnicity: :breakdown,
      percent_passing: :value,
      content_area: :subject,
      test_level: :grade,
      science_percent_passing: :value
    })
    .transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above',
    })
    .transform('skip Migrant and Homeless breakdowns',DeleteRows,:breakdown, 'Migrant', 'Homeless') 
    .transform('skip * value',DeleteRows,:value, '*')   
    .transform('skip Grade 8 Enrolled value',DeleteRows,:grade, 'Grade 8 Enrolled Algebra 1','Grade 8 Enrolled Algebra 2','Grade 8 Enrolled All Math Assessment','Grade 8 Enrolled Geometry')   
    .transform("Process inequalities", WithBlock) do |row|
      if row[:test_data_type_id] == 207
        if row[:value] == '<2' or row[:value] == '>98'
          if row[:science_percent_exceeds] !~ /\D/ and row[:science_percent_meets] !~ /\D/
            row[:value] = row[:science_percent_exceeds].to_i + row[:science_percent_meets].to_i
          elsif row[:science_percent_approaches] !~ /\D/ and row[:science_percent_falls_far_below] !~ /\D/
            row[:value] = 100 - (row[:science_percent_approaches].to_i + row[:science_percent_falls_far_below].to_i)
          end   
        end
      end
      row
    end 
    .transform("Assign grade and subject", WithBlock) do |row|
      if row[:test_data_type_id] == 208
        if row[:grade] == 'Grade 8 Enrolled Grade 8 Assessment'
          row[:grade] = '8'
        elsif row[:grade] =~ /\d/
          row[:grade].gsub!('Grade ','')
        elsif row[:grade] != 'All'
          row[:subject] = row[:grade]
          row[:grade] = 'All'
        end
      else
        if row[:grade] == '2020'
          row[:grade] = '9'
        elsif row[:grade] == '2019'
          row[:grade] = '10' 
        elsif row[:grade] == '2018'
          row[:grade] = '11' 
        elsif row[:grade] == 'All Grades'
          row[:grade] = 'All'
        end
      end
      row
    end
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:school_id].rjust(5,'0')  
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:district_id].rjust(5,'0')
      else
        row[:state_id] = 'state'
      end
      row
    end
  end

  def config_hash
    {
        source_id: 6,
        state: 'az'
    }
  end
end

AZTestProcessor2017AIMSAZMERIT.new(ARGV[0], max: nil).run