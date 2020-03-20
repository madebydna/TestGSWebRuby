require_relative "../test_processor"

class NETestProcessor2017NSCASNESAELA < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2017
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


  source("ela_2017.txt",[], col_sep: "\t") do |s|
    s.transform('Fill missing default fields', Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      subject_id: 4,
      test_data_type: 'NSCAS',
      test_data_type_id: 360,
      notes: 'DXT-3128: NE NSCAS',
      description: 'In 2016-2017 Nebraska used the Nebraska Student-Centered Assessment System (NSCAS) assessment to test students in grades 3 through 8 and 11 in english language arts. Nebraska also used the Nebraska State Accountability (NeSA) to test students in grades 3 through 8 and 11 in math, and in grades 5, 8 and 11 in science. These assessments are standards-based tests, which means it measures how well students are mastering specific skills defined for each grade by the state of Nebraska. The goal is for all students to score at or above proficient on the test.',
      proficiency_band_id: 1,
      proficiency_band: 'proficient and above'
    })
    .transform('Rename column headers', MultiFieldRenamer,{
      type: :entity_type,
      student_subgroup: :breakdown
    })
    .transform('load year 2017',DeleteRows, :school_year, '2017-2018')
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
    .transform('Set up state_id',WithBlock) do |row|
      if row[:entity_type] == 'school'
        row[:state_id] = row[:county].rjust(2,'0') + row[:district].rjust(4,'0') + row[:school].rjust(3,'0')
      elsif row[:entity_type] == 'district'
        row[:state_id] = row[:county].rjust(2,'0') + row[:district].rjust(4,'0') + "000"
      else
        row[:state_id] = 'state'
      end
      row
    end
    .transform("Skip invalid type", DeleteRows, :type, 'LC')  
    .transform("Skip invalid values", DeleteRows, :average_scale_score, '-1')    
    .transform('skip subgroups', DeleteRows, :breakdown, 'Highly Mobile Students', 'Foster Care', 'Homeless', 'Special Education Students - Alternate Assessment', 'Students served in migrant programs', 'Parent in Military')  
    .transform("Process prof and above", WithBlock) do |row|
      if row[:proficient_pct] != '-1' && row[:advanced_pct] != '-1'
        row[:value] = (row[:proficient_pct].to_f + row[:advanced_pct].to_f)*100
      elsif (row[:proficient_pct] == '-1' || row[:advanced_pct] == '-1') && row[:basic_pct] != '-1'
        row[:value] = 100 - row[:basic_pct].to_f*100
      elsif (row[:proficient_pct] == '-1' || row[:advanced_pct] == '-1') && row[:basic_pct] == '-1'
        row[:value] = 'skip'
      end
      row
    end 
    .transform('skip bad values',DeleteRows,:value,'skip')
    .transform('Map breakdown_id',HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id) 
  end

  def config_hash
    {
        source_id: 31,
        state: 'ne'
    }
  end
end

NETestProcessor2017NSCASNESAELA.new(ARGV[0], max: nil).run