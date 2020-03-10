require_relative "../test_processor"

class MNTestProcessor2018MCA3 < GS::ETL::TestProcessor

  def initialize(*args)
    super
    @year = 2018
  end


  key_map_bd = {
    '5-White' => 21,
    'W-White' => 21,
    'All Students' => 1,
    '3-Hispanic' => 19,
    'H-Hispanic/Latino' => 19,
    'Receiving Special Education Services' => 27,
    '1-American Indian' => 18,
    'I-American Indian/Alaska Native' => 18,
    'Not eligible for Free/Reduced Priced Meals' => 24,
    'Male' => 25,
    'Female' => 26,
    'Not receiving Special Education Services' => 30,
    'Not eligible for EL Services' => 33,
    'Eligible for Free/Reduced Priced Meals' => 23,
    '2-Asian / Pacific Islander' => 16,
    'A-Asian' => 16,
    '4-Black' => 17,
    'B-Black/African American' => 17,
    'Eligible for EL Services' => 32,
    'M-Two or More Races' => 22, 
    'P-Native Hawaiian/Pacific Islander' => 20
  }

  key_map_sub = {
    'reading' => 2,
    'math' => 5,
    'science' => 19,
    'high school science' => 83
  }

  key_map_pro = {
      :"percentlevel1" => 5,
      :"percentlevel2" => 6,
      :"percentlevel3" => 7,
      :"percentlevel4" => 8,
      :"percentleveld" => 5,
      :"percentlevelp" => 6,
      :"percentlevelm" => 7,
      :"percentlevele" => 8,
      :"proficient_and_above" => 1
  }

    key_grade = {
      '03' => 3,
      '04' => 4,
      '05' => 5,
      '06' => 6,
      '07' => 7,
      '08' => 8,
      '09' => 9
  }

  source("2017MCA3MathPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      subject: 'math',
      description: 'In 2016-17, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
    .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2017MCA3ReadingPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2017,
        date_valid: '2017-01-01 00:00:00',
        subject: 'reading',
        description: 'In 2016-17, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2017MCA3SciencePublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      year: 2017,
      date_valid: '2017-01-01 00:00:00',
      subject: 'science',
      description: 'In 2016-17, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("add levels m and e for null prof band", SumValues, :proficient_and_above, :percentlevelm, :percentlevele)
  end
  source("2017MCA3MathNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2017,
        date_valid: '2017-01-01 00:00:00',
        subject: 'math',
        description: 'In 2016-17, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("Renaming fields to process for non public", MultiFieldRenamer,
      {
        summarylevel: :entity_type
      })
     .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer', 'state')
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2017MCA3ReadingNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2017,
        date_valid: '2017-01-01 00:00:00',
        subject: 'reading',
        description: 'In 2016-17, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("Renaming fields to process for non public",
      MultiFieldRenamer,
      {
        summarylevel: :entity_type
      })
     .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer', 'state')
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2017MCA3ScienceNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2017,
        date_valid: '2017-01-01 00:00:00',
        subject: 'science',
        description: 'In 2016-17, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("Renaming fields to process for non public",
      MultiFieldRenamer,
      {
        summarylevel: :entity_type
      })
     .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer', 'state')
     .transform("add levels m and e for null prof band", SumValues, :proficient_and_above, :percentlevelm, :percentlevele)
  end
  #2018
    source("2018MCA3MathPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2018,
        date_valid: '2018-01-01 00:00:00',
        subject: 'math',
        description: 'In 2017-18, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2018MCA3ReadingPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2018,
        date_valid: '2018-01-01 00:00:00',
        subject: 'reading',
        description: 'In 2017-18, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2018MCA3SciencePublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2018,
        date_valid: '2018-01-01 00:00:00',
        subject: 'science',
        description: 'In 2017-18, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("add levels m and e for null prof band", SumValues, :proficient_and_above, :percentlevelm, :percentlevele)
  end
  source("2018MCA3MathNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
      year: 2018,
      date_valid: '2018-01-01 00:00:00',
      subject: 'math',
      description: 'In 2017-18, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
     .transform("Renaming fields to process for non public",
      MultiFieldRenamer,
      {
        summarylevel: :entity_type
      })
     .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer', 'state')
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
   end
  source("2018MCA3ReadingNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2018,
        date_valid: '2018-01-01 00:00:00',
        subject: 'reading',
        description: 'In 2017-18, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
      .transform("Renaming fields to process for non public",
      MultiFieldRenamer,
      {
        summarylevel: :entity_type
      })
     .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer', 'state')
     .transform("add levels 3 and 4 for null prof band", SumValues, :proficient_and_above, :percentlevel3, :percentlevel4)
  end
  source("2018MCA3ScienceNonPublicFilter9.txt",[], col_sep: "\t") do |s|
    s.transform("Fill missing default fields", Fill, {
        year: 2018,
        date_valid: '2018-01-01 00:00:00',
        subject: 'science',
        description: 'In 2017-18, Minnesota used the Minnesota Comprehensive Assessment-III (MCA-III) to test in math in grades 3 through 8 and 11, in reading in grades 3 through 8 and 10, and in science for grades 5 and 8, and once in high school. The MCA-III is a standards-based test, which means it measures specific skills defined for each grade by the state of Minnesota. The goal is for all students to score at or above the state standard.'
    })
      .transform("Renaming fields to process for non public",
      MultiFieldRenamer,
      {
        summarylevel: :entity_type
      })
     .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer', 'state')
     .transform("add levels m and e for null prof band", SumValues, :proficient_and_above, :percentlevelm, :percentlevele)
  end

  shared do |s|
    s.transform("Renaming fields",
      MultiFieldRenamer,
      {
        reportdescription: :breakdown,
        counttested: :number_tested,
        summarylevel: :entity_type,
        districtname: :district_name,
        schoolname: :school_name
      })
    .transform("Remove weird breakdowns", DeleteRows, :breakdown, 'Enrolled in Same School On October 1','Not enrolled in Same School On October 1','Not Identified as Homeless','Not eligible for Migrant Services','Not Identified as SLIFE','Identified as Homeless','Identified as SLIFE','Eligible for Migrant Services')
    .transform("Delete rows where number tested is less than 10", DeleteRows, :filtered, 'Y')
    .transform("Delete ",DeleteRows, :entity_type, 'county','economicDevRegion','charterAuthorizer')
    .transform("Fill missing default fields", Fill, {
      test_data_type: 'mca3',
      test_data_type_id: 267,
      notes: 'DXT-3123: MN MCA3 2017-2018 test load.'
    })
    .transform("transpose prof bands", Transposer,
      :proficiency_band,
      :value,
      :"percentlevel1",
      :"percentlevel2",
      :"percentlevel3",
      :"percentlevel4",
      :"percentleveld",
      :"percentlevelp",
      :"percentlevelm",
      :"percentlevele",
      :"proficient_and_above")
    .transform("Set grade for high school science", WithBlock,) do |row|
      if row[:subject] == 'science' and row[:grade] == 'HS'
        row[:subject] = 'high school science'
        row[:grade] = 'All'
      end
      row
    end
    .transform("Adding column breakdown_id from breadown",
      HashLookup, :breakdown, key_map_bd, to: :breakdown_id)
    .transform("Adding column subject_id from subject",
      HashLookup, :subject, key_map_sub, to: :subject_id)
    .transform("Adding column _id from proficiency band",
      HashLookup, :proficiency_band, key_map_pro, to: :proficiency_band_id)
    .transform("Fixing grade 0 padding",
      HashLookup, :grade, key_grade, to: :grade)
    .transform("Creating StateID", WithBlock) do |row|
      if row[:entity_type] == 'district'
          row[:state_id] = row[:districttype].rjust(2,'0') + row[:districtnumber].rjust(4,'0')
      elsif row[:entity_type] == 'school'
        row[:district_id] = row[:districttype].rjust(2,'0') + row[:districtnumber].rjust(4,'0')
        row[:state_id] = row[:districttype].rjust(2,'0') + row[:districtnumber].rjust(4,'0') + row[:schoolnumber].rjust(3,'0')
      end
      row
    end
    .transform("Prof special cases", WithBlock,) do |row|
      if row[:value].to_f < 0
        row[:value] = 0
      elsif row[:value].to_f > 100
        row[:value] = 100
      elsif row[:value] == '.0'
        row[:value] = 0
      end
      row
    end
        # .transform('Fill missing ids and names with entity_type', WithBlock) do |row|
    #   [:state_id, :school_id, :district_id, :school_name, :district_name].each do |col|
    #     row[col] ||= row[:entity_type]
    #   end
    #   row
    # end
  end

  def config_hash
    {
        source_id: 27,
        state: 'mn'
    }
  end
end

MNTestProcessor2018MCA3.new(ARGV[0], max: nil).run
