require_relative "../test_processor"

class AZTestProcessor20182019AIMSAZMERIT < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2019
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
    "English Learner" => 32,
    "Economic Disadvantage" => 23,
    "Economically Disadvantaged" => 23,
    "Income Eligibility 1 and 2" => 23          
  }

  subject_id_map = {
    'Science' => 19,
    'Math' => 5,
    'Mathematics' => 5,
    'English Language Arts' => 4,
    'Algebra I' => 6,
    'Algebra II' => 10,
    'Geometry' => 8
   }



  source("aims_state_by_grade_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'state',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2017-2018, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      breakdown_id: 1,
      subject_id: 19
    })
  end

  source("aims_districts_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'district',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2017-2018, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      breakdown_id: 1,
      subject_id: 19,
      grade: 'All'
    })
  end

  source("aims_districts_by_grade_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'district',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2017-2018, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      breakdown_id: 1,
      subject_id: 19
    })
  end

  source("aims_schools_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'school',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2017-2018, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      breakdown_id: 1,
      subject_id: 19,
      grade: 'All'
    })
  end

  source("aims_schools_by_grade_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'school',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2017-2018, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      breakdown_id: 1,
      subject_id: 19
    })
  end

  source("aims_state_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      entity_type: 'state',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2018-2019, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      subject_id: 19
    })
  end

  source("aims_districts_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      entity_type: 'district',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2018-2019, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      subject_id: 19
    })
  end

  source("aims_schools_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      entity_type: 'school',
      test_data_type: 'AIMS',
      test_data_type_id: 207,
      description: 'In 2018-2019, Arizona used the Arizona Instrument to Measure Standards (AIMS) to test students in science in grades 4, 8 and high school students in grades 9-11. AIMS is a standards-based test, which means that it measures how well students have mastered Arizona learning standards. The goal is for all students to meet or exceed state standards on the test.',
      notes: 'DXT-3370: AZ AIMS',
      subject_id: 19
    })
  end


  source("azmerit_state_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      entity_type: 'state',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2018-2019, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8 for Math, and grades 3-11 for English Language Arts. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3370: AZ AZMerit'
    })
  end


  
  source("azmerit_districts_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      entity_type: 'district',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2018-2019, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8 for Math, and grades 3-11 for English Language Arts. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3370: AZ AZMerit'
    })
  end

  source("azmerit_schools_2019.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2019,
      date_valid: '2019-01-01 00:00:00',
      entity_type: 'school',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2018-2019, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8 for Math, and grades 3-11 for English Language Arts. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3370: AZ AZMerit'
    })
  end


  source("azmerit_state_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'state',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2017-2018, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8 for Math, and grades 3-11 for English Language Arts. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3370: AZ AZMerit'
    })
  end

  
  source("azmerit_districts_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'district',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2017-2018, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8 for Math, and grades 3-11 for English Language Arts. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3370: AZ AZMerit'
    })
  end

  source("azmerit_schools_2018.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      entity_type: 'school',
      test_data_type: 'AZMerit',
      test_data_type_id: 208,
      description: 'In 2017-2018, students in Arizona took the AZMerit. Arizona\'s Measurement of Educational Readiness to Inform Teaching (AzMERIT) is an annual statewide test that measures how students are performing in English language arts and math for students in grade 3-8 for Math, and grades 3-11 for English Language Arts. The AZ Merit is also used to assess students for End of Course assessments for Algebra I, Algebra II, and Geometry.',
      notes: 'DXT-3370: AZ AZMerit'
    })
  end


  shared do |s|
    s.transform('Rename column headers', MultiFieldRenamer,{
      school_number: :school_name,
      subgroup: :breakdown,
      percent_passing: :value,
      content_area: :subject,
      test_level: :grade,
      science_percent_passing: :value
    })
    .transform('Fill missing default fields', Fill, {
      proficiency_band_id: 1
    })
    .transform('skip Migrant, Military, and Homeless breakdowns',DeleteRows,:breakdown,'Migrant','Military','Homeless') 
    .transform('skip school types',DeleteRows,:school_type,'Alternative School','District','Charter','Alternative') 
    .transform('skip district types',DeleteRows,:district_type,'Alternative School','District','Charter','Alternative') 
    .transform('skip * value',DeleteRows,:value, '*')   
    .transform('skip Grade 8 Enrolled value',DeleteRows,:grade, 'Grade 8 Enrolled Algebra 1','Grade 8 Enrolled Algebra 2','Grade 8 Enrolled All Math Assessment','Grade 8 Enrolled Geometry', 'ACT Science')   
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
        if row[:grade] == 'Grade 8 Enrolled Grade 8 Assessment' || row[:grade] == 'Grade 8 Enrolled Grade 8 Math Assessment' ||  row[:grade] == 'Grade 8 enrolled Grade 8 assessment'
          row[:grade] = '8'
        elsif row[:grade] =~ /\d/
          if row[:year] == 2019
            row[:grade].gsub!(/(ELA|Mathematics) Grade /, '')
          else
            row[:grade].gsub!('Grade ', '')
          end
        elsif row[:grade] == 'All Assessments'
          row[:grade] = 'All'
        elsif row[:grade] != 'All'
          row[:subject] = row[:grade]
          row[:grade] = 'All'
        end
      else
        if row[:year] == 2018
          if row[:grade] == '2021'
            row[:grade] = '9'
          elsif row[:grade] == '2020'
            row[:grade] = '10' 
          elsif row[:grade] == '2019'
            row[:grade] = '11'
          elsif row[:grade] == 'All Grades'
            row[:grade] = 'All'
          end
        else
          if row[:grade] == '2022'
            row[:grade] = '9'
          elsif row[:grade] == '2021'
            row[:grade] = '10' 
          elsif row[:grade] == '2020'
            row[:grade] = '11'
          elsif row[:grade] == 'All Assessments'
            row[:grade] = 'All'
          end
        end
      end
      row
    end
    .transform('Map subject_id',HashLookup, :subject, subject_id_map, to: :subject_id)               
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:school_code].rjust(5,'0')  
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:district_code].rjust(5,'0')
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

AZTestProcessor20182019AIMSAZMERIT.new(ARGV[0], max: nil).run