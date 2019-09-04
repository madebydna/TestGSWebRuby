require_relative "../test_processor"

class KSTestProcessor2018Ksa < GS::ETL::TestProcessor
  #GS::ETL::Logging.disable

  def initialize(*args)
    super
    @year = 2018
  end


  breakdown_id_map={
    'Female' => 26,
    'Male' => 25,
    'American Indian or Alaskan Native' => 18,
    'Asian' => 16,
    'African American' => 17,
    'Hispanic' => 19,
    'Multi Racial' => 22,
    'White' => 21,
    'ELL' => 32,
    'Free and Reduced Lunch' => 23,
    'All Students' => 1,
    'Native Hawaiian or Pacific Islander' => 20, 
    'Not Disabled' => 30,
    'Students with Disabilities' => 27
  }

  subject_id_map={
    'Math' => 5,
    'ELA' => 4,
    'Science' => 19,
    'History/Government' => 52
  }

  proficiency_band_id_map={
    :pct_level_1 => 5,
    :pct_level_2 => 6,
    :pct_level_3 => 7,
    :pct_level_4 => 8,
    :proficient_and_above => 1
  }

  grade_map = {
      'Grade 03' => 3,
      'Grade 04' => 4,
      'Grade 05' => 5,
      'Grade 06' => 6,
      'Grade 07' => 7,
      'Grade 08' => 8,
      'All Grades' => 'All'
  }


  source("KS_Test_Results_2015_16_060419.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      year: 2016,
      date_valid: '2016-01-01 00:00:00',
      description: 'In 2015-16, Kansas used the Kansas State Assessments (KSA) to test students in grades 3 though 8, and 10 in reading and math. Students were tested in science, but these results were not released. The tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Kansas. The goal is for all students to score at or above the state standard.'
    })
    .transform("Set hs grade by subject", WithBlock,) do |row|
      if row[:grade] == 'HS'
        row[:grade] = 10
      end
      row
    end
  end

  source("KS_Test_Results_2016_17_072519.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      description: 'In 2016-17, Kansas used the Kansas State Assessments (KSA) to test students in grades 3 though 8, and 10 in reading and math, and in grades 5,8,11 in science. The tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Kansas. The goal is for all students to score at or above the state standard.'
    })
    .transform("Set hs grade by subject", WithBlock,) do |row|
      if row[:grade] == 'HS' and row[:subject] == 'Science'
        row[:grade] = 11
      elsif row[:grade] == 'HS'
        row[:grade] = 10
      end
      row
    end
  end

  source("KS_Test_Results_2017_18_072519.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      description: 'In 2017-18, Kansas used the Kansas State Assessments (KSA) to test students in grades 3 though 8, and 10 in reading and math. Students were also tested in grades 5,8,11 in science, and grades, 6,8, and 11 in history and government. The tests are standards-based, which means they measure how well students are mastering specific skills defined for each grade by the state of Kansas. The goal is for all students to score at or above the state standard.'
    })
    .transform("Set hs grade by subject", WithBlock,) do |row|
      if row[:grade] == 'HS' and row[:subject] == 'Science'
        row[:grade] = 11
      elsif row[:grade] == 'HS' and row[:subject] == 'History/Government'
        row[:grade] = 11
      elsif row[:grade] == 'HS'
        row[:grade] = 10
      end
      row
    end
  end

  shared do |s|


    s.transform("Rename columns",MultiFieldRenamer,
      {
        subgroup: :breakdown,
        n_tested: :number_tested
        })
     .transform("Fill entity_type and level_code", Fill, {
      test_data_type: 'KSA',
      test_data_type_id: 243,
      notes: 'DXT-2440: KS KSA'
      })
     .transform("remove NA rows - fully suppressed", DeleteRows, :number_tested, 'NA','0','1','2','3','4','5','6','7','8','9')
     .transform("sum levels 3 and 4 for prof and above", SumValues, :proficient_and_above, :pct_level_3, :pct_level_4)
     .transform("transpose prof bands", Transposer,
      :proficiency_band,
      :value,
      :"pct_level_1",
      :"pct_level_2",
      :"pct_level_3",
      :"pct_level_4",
      :"proficient_and_above")
     .transform("Prof special cases", WithBlock,) do |row|
      if row[:value].to_f < 0
        row[:value] = 0
      elsif row[:value].to_f > 100
        row[:value] = 100
      end
      row
     end
     .transform("map breakdown to id", HashLookup, :breakdown, breakdown_id_map, to: :breakdown_id)
     .transform('map subject to ids', HashLookup, :subject, subject_id_map, to: :subject_id)
     .transform('map proficiency band to ids', HashLookup, :proficiency_band, proficiency_band_id_map, to: :proficiency_band_id)
     .transform('map grade', HashLookup, :grade, grade_map, to: :grade)
     .transform('Create state_ids, set entity level', WithBlock) do |row|
      if row[:district_id]=='State'
        row[:entity_type]='state'
        row[:state_id]='state'
      elsif row[:school_id]=='0'
        row[:entity_type]='district'
        row[:state_id]=row[:district_id]
      else
        row[:entity_type]='school'
        row[:state_id]=row[:school_id].rjust(4, '0')
      end
      row
     end
     # .transform('Remove leading grade zeros', WithBlock) do |row|
     #    row[:grade].gsub!('0','') if row[:grade][0]=='0'
     #    row
     # end
      # .transform('Remove blank values', WithBlock) do |row|
      #   row if row[:value]!=''
      # end
      # .transform('',WithBlock) do |row|
      #   require 'byebug'
      #   byebug
      # end
      # .transform('Remove suppressed rows', WithBlock) do |row|
      #   row if row[:number_tested] != '<10*'
      # end
      # .transform('Create prof null column', SumValues, :null, :l3, :l4, :l5)
      # .transform('Transpose proficiency bands', Transposer, :proficiency_band, :value_float, :l1, :l2, :l3, :l4, :l5, :null)
      # .transform('Skip row for band 5 if not a science exam', WithBlock) do |row|
      #   row unless row[:proficiency_band]==:l5 and row[:subject]!='Science'
      # end
      # .transform('Look up proficiency band ids', WithBlock) do |row|
      #   if row[:subject]=='Science'
      #     row[:proficiency_band_id] = proficiency_band_id_map_science[row[:proficiency_band]]
      #   else
      #     row[:proficiency_band_id] = proficiency_band_id_map[row[:proficiency_band]]
      #   end
      #   row
      # end
      # .transform('Remove % characters from value_float', WithBlock) do |row|
      #   if row[:value_float] =~ /%/
      #     row[:value_float].gsub!('%','')
      #   end
      #   row
      # end
  end

  def config_hash
    {
        source_id: 20,
        state: 'ks'
    }
  end
end

KSTestProcessor2018Ksa.new(ARGV[0], max: nil).run